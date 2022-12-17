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

  outputs = { self, nixpkgs, hyprland, home-manager }: {
    nixosConfigurations.humus = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        userModule = import ./userModule.nix;
      };
      modules = [
        hyprland.nixosModules.default
        home-manager.nixosModules.default
        ./users/humus
        ./modules/mpd
        {
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            sandbox = true;
          };
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "osu-lazer"
            "steam"
          ];
          # system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          system.stateVersion = "22.05";
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
          };
        }
        ({ pkgs, ... }: {
          imports = [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
          ];

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

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

          networking.hostName = "humus";
        })
        ({ pkgs, ... }: {
          hardware.bluetooth = {
            enable = true;
            settings = {
              General.Enable = "Source,Sink,Media,Socket";
            };
          };

          networking.networkmanager.enable = true;

          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            wireplumber.enable = true;
          };
          xdg.portal = {
            enable = true;
            wlr.enable = true;
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          };

          services.printing = {
            enable = true;
            drivers = [ pkgs.brlaser ];
          };

          services.openssh = {
            enable = true;
          };
          
          users.users.papa = {
            isNormalUser = true;
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
