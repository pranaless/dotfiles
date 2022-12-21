{ nixpkgs, home-manager, ... }:
with nixpkgs.lib;
let
  hm = home-manager.lib.hm;
in {
  themeType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the theme.";
      };
      
      font = mkOption {
        type = types.nullOr hm.types.fontType;
        default = null;
      };
    };
  };
}
