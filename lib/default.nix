{ self, lib, home-manager }:
with lib;
let callLibFile = f: import f { inherit lib; self = self.lib; };
in rec {
  options = callLibFile ./options.nix;
  colors = callLibFile ./colors.nix;
  types = callLibFile ./types.nix;

  inherit (options) super;

  mkHosts = builtins.mapAttrs (hostName: {
    system,
    flakes ? {},
    modules ? []
  }: let
    flakesPkgs = builtins.mapAttrs (_: flake: flake.packages.${system}) flakes;
  in nixosSystem {
    inherit system;
    modules = [
      home-manager.nixosModules.default
      ../modules
      {
        config = {
          _module.args.dlib = self.lib;
          home-manager.sharedModules = [{
            config._module.args.dlib = self.lib;
          }];
          
          nixpkgs.overlays = [
            (import ../pkgs)
            (self: super: flakesPkgs)
          ];
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
