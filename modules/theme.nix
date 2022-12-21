{ lib, dlib, config, ... }:
with lib;
let
  cfg = config.theme;
in {
  options.theme = mkOption {
    type = types.nullOr dlib.types.themeType;
    default = null;
  };
  config = mkIf (cfg != null) {
    home.packages = let
      optionalPackage = opt:
        optional (opt != null && opt.package != null) opt.package;
    in concatMap optionalPackage [
      cfg.font
    ];
  };
}
