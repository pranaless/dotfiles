{ self, lib, home-manager }:
with lib;
let
  importLibFile = f: import f { inherit lib; self = self.lib; };
in rec {
  colors = importLibFile ./colors.nix;
  modules = importLibFile ./modules.nix;
  options = importLibFile ./options.nix;
  types = importLibFile ./types.nix;

  inherit (modules) mkIfNotNull mkIfNotNullMap;
  inherit (options) super;
}
