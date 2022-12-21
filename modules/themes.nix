{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.themes;
  module = { name, config, ... }: {
    options = {
      enable = mkEnableOption name;
    
      package = mkOption {
        type = types.package;
        description = "Package providing the theme.";
      };
      
      font = mkOption {
        type = types.nullOr hm.types.fontType;
        default = null;
      };
    };
    config =
    let
      optionalPackage = opt:
        optional (opt != null && opt.package != null) opt.package;
    in {
      package = pkgs.symlinkJoin {
        inherit name;
        paths = concatMap optionalPackage [
          config.font
        ];
      };
    };
  };
in {
  options.themes = {
    themes = mkOption {
      type = with types; attrsOf (submodule module);
      default = { };
    };
  };
  config = mkIf (cfg.themes != { }) {
    home.packages = concatMap (opt: optional opt.enable opt.package)
      (attrValues cfg.themes);
  };
}
