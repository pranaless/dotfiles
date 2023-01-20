{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.theme.helix = {
    name = dlib.super options.theme.name;
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
    programs.helix.settings = {
      theme = theme.name;
    };
  };
}
