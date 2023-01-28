{ pkgs, lib, config, options, ... }:

with lib;
let cfg = config.settings.helix;
in {
  options.settings.helix = {
    name = dl.super options.settings.theme;
    theme = mkOption {
      type = types.nullOr (pkgs.formats.toml {}).type;
      default = null;
    };
  };
  options.programs.helix.useSettings = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf (config.programs.helix.enable && config.programs.helix.useSettings) {
    programs.helix = {
      themes.${cfg.name} = mkIf (cfg.theme != null) cfg.theme;
      settings = {
        theme = cfg.name;
      };
    };
  };
}
