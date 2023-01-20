{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.theme.helix = {
    name = dlib.super options.theme.name;
    theme = mkOption {
      type = types.nullOr (pkgs.formats.toml {}).type;
      default = null;
    };
  };
  options.programs.helix.useTheme = mkOption {
    type = types.bool;
    default = false;
  };

  config =
  let
    cfg = config.programs.helix;
    theme = config.theme.helix;
  in mkIf (cfg.enable && cfg.useTheme) {
    programs.helix = {
      themes.${theme.name} = mkIf (theme.theme != null) theme.theme;
      settings = {
        theme = theme.name;
      };
    };
  };
}
