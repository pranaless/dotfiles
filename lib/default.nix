{ self, lib, home-manager }:
with lib;
rec {
  types = import ./types.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };

  inherit (options) super;

  mkHost = {
    hostName,
    system,
    modules ? {}
  }:
  {
    ${hostName} = nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.default
        ../modules
        ({ pkgs, lib, ... }: {
          config = {
            _module.args.dlib = self.lib;
            home-manager.sharedModules = [{
              config._module.args.dlib = self.lib;
            }];
            
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              sandbox = true;
            };
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
            };

            system.configurationRevision = mkIf (self ? rev) self.rev;

            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
      
            networking.hostName = hostName;
          };
        })
      ] ++ modules;
    };
  };
}
