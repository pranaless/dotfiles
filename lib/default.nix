{ self, lib, home-manager }:
with lib;
rec {
  types = import ./types.nix { inherit lib; };
  options = import ./options.nix { inherit lib; };

  inherit (options) super;

  mkHosts = builtins.mapAttrs (hostName: {
    system,
    flakes ? {},
    modules ? []
  }: let
    args = builtins.mapAttrs (_: flake: flake.packages.${system}) flakes // {
      dlib = self.lib;
    };
  in nixosSystem {
    inherit system;
    modules = [
      home-manager.nixosModules.default
      ../modules
      {
        config = {
          _module.args = args;
          home-manager.sharedModules = [{
            config._module.args = args;
          }];
          
          nixpkgs.overlays = [ (import ../pkgs) ];
          nix.settings = {
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
}
