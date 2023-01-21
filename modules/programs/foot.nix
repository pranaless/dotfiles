{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.theme.foot = dlib.super options.theme.terminal;
  options.programs.foot.useTheme = mkOption {
    type = types.bool;
    default = false;
  };
  
  config =
  let
    cfg = config.programs.foot;
    theme = config.theme.foot;
  in mkIf (cfg.enable && cfg.useTheme) {
    programs.foot.settings = {
      main = {
        font = mkIf (theme.font != null) "${theme.font.name}:size=${toString theme.font.size}"; # FIXME: handle fonts more robustly
      };
      colors = let cfg = theme.colors;
      in mkMerge [
        (mkIf (cfg.palette != null)
          (listToAttrs (imap0 (i: c: {
            name = if i <= 7 then "regular${toString i}" else "bright${toString (i - 8)}";
            value = c;
          }) cfg.palette)))
        {
          foreground = mkIf (cfg.foreground != null) cfg.foreground;
          background = mkIf (cfg.background != null) cfg.background;
        }
      ];
    };
  };
}
