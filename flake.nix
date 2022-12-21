{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland }@inputs:
  let
    mkHost = self.lib.mkHost;
  in {
    lib = import ./lib.nix inputs;
    
    nixosConfigurations = mkHost {
      hostName = "humus";
      system = "x86_64-linux";
      modules = [
        hyprland.nixosModules.default
        ./users/humus
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "osu-lazer"
            "steam"
          ];
          # system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          system.stateVersion = "22.05";
        }
        ({ pkgs, ... }: {
          imports = [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
          ];

          # Not sure if this actually helps?
          boot.initrd.availableKernelModules = [
            "aesni_intel"
            "cryptd"
          ];

          fileSystems = {
            "/".options = [ "compress=zstd" ];
            "/home".options = [ "compress=zstd" ];
            "/nix".options = [ "compress=zstd" "noatime" ];
          };
          swapDevices = [ { device = "/swap"; } ];

          environment.systemPackages = with pkgs; [
            btrfs-progs
          ];

          time.timeZone = "UTC";
          i18n.defaultLocale = "en_US.UTF-8";
        })
        ({ pkgs, ... }: {
          networking.networkmanager.enable = true;

          services.printing = {
            enable = true;
            drivers = [ pkgs.brlaser ];
          };

          services.openssh = {
            enable = true;
          };
          
          environment.systemPackages = with pkgs; [
            winetricks
            wineWowPackages.waylandFull
          ];
          programs.hyprland.enable = true;
          programs.steam.enable = true;
        })
      ];
    };
  };
}
