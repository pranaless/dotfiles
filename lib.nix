{ self, nixpkgs, home-manager, ... }:
{
  mkHost = {
    hostName,
    system,
    modules ? {}
  }:
  {
    ${hostName} = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.default
        ./modules
        {
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            sandbox = true;
          };
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
          };

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
        
          networking.hostName = hostName;
        }
      ] ++ modules;
    };
  };
}
