{ self, lib, home-manager }:
with lib;
let
  importLibFile = f: import f { inherit lib; self = self.lib; };
  extendLib = lib: lib.extend (_: _: { dl = self.lib; });
in rec {
  colors = importLibFile ./colors.nix;
  modules = importLibFile ./modules.nix;
  options = importLibFile ./options.nix;
  types = importLibFile ./types.nix;

  inherit (modules) mkIfNotNull mkIfNotNullMap;
  inherit (options) super;

  mkHosts = builtins.mapAttrs (hostName: {
    system,
    flakes ? {},
    modules ? []
  }: let
    flakesPkgs = builtins.mapAttrs (_: flake: flake.packages.${system}) flakes;
  in nixosSystem {
    inherit system;
    lib = extendLib lib;
    modules = [
      home-manager.nixosModules.default
      ../modules
      {
        config = {
          nixpkgs.overlays = [
            (self: super: {
              lib = extendLib super.lib;
            })
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
