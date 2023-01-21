{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.settings.helix = {
    name = dlib.super options.settings.theme;
    theme = mkOption {
      type = types.nullOr (pkgs.formats.toml {}).type;
      default = null;
    };
  };
  options.programs.helix.useSettings = mkOption {
    type = types.bool;
    default = false;
  };

  config =
  let
    cfg = config.settings.helix;
  in mkIf (config.programs.helix.enable && config.programs.helix.useSettings) {
    programs.helix = {
      themes.${cfg.name} = mkIf (cfg.theme != null) cfg.theme;
      settings = {
        theme = cfg.name;
      };
    };
  };
}
