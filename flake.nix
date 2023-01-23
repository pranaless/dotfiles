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

  outputs = { self, nixpkgs, home-manager, hyprland }:
  let
    lib = import ./lib {
      inherit self home-manager;
      lib = nixpkgs.lib.extend (self: super: {
        dl = lib;
      });
    };
  in {
    inherit lib;
  
    nixosConfigurations = lib.mkHosts {
      humus = {
        system = "x86_64-linux";
        flakes = { inherit hyprland; };
        modules = [
          hyprland.nixosModules.default
          ./users/humus
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              "osu-lazer"
              "steam"
            ];
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
            programs.hyprland = {
              enable = true;
              package = pkgs.hyprland.hyprland;
            };
            programs.steam.enable = true;
          })
        ];
      };
    };
  };
}
