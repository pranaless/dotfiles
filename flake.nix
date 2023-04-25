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
      inherit (nixpkgs) lib;
    };
    mkHosts = with nixpkgs.lib; let
      extendLib = l: l.extend (_: _: { dl = lib; });
    in builtins.mapAttrs (hostName: {
      system,
      # flakes ? {},
      modules ? []
    }: let
      # flakesPkgs = builtins.mapAttrs (_: flake: flake.packages.${system}) flakes;
    in nixosSystem {
      inherit system;
      lib = extendLib nixpkgs.lib;
      modules = [
        home-manager.nixosModules.default
        ./modules
        {
          config = {
            nixpkgs.overlays = [
              (self: super: {
                lib = extendLib super.lib;
              })
              (import ./pkgs)
              # (self: super: flakesPkgs)
            ];
            nix.settings = {
              trusted-users = [ "@wheel" ];
              experimental-features = [ "nix-command" "flakes" ];
              sandbox = true;
            };
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
            };
            system.configurationRevision = mkIf (self ? rev) self.rev;
          };
        }
        {
          config = {
            boot.loader.systemd-boot.enable = mkDefault true;
            boot.loader.efi.canTouchEfiVariables = mkDefault true;

            networking.hostName = hostName;
          };
        }
      ] ++ modules;
    });
  in {
    inherit lib;
  
    nixosConfigurations = mkHosts {
      humus = {
        system = "x86_64-linux";
        # flakes = { };
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

            programs.steam.enable = true;
          })
        ];
      };
    };
  };
}
