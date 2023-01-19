{ lib, config, ... }:
with lib;
let cfg = config.theme.font;
in {
  options.theme.font = mkOption {
    type = types.nullOr hm.types.fontType;
    default = null;
  };
  
  config = mkIf (cfg != null) {
    home.packages = optional (cfg.package != null) cfg.package;
  };
}
