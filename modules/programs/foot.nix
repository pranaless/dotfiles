{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.theme.foot = 
  let
    opt = options.theme;
    cfg = config.theme;
  in {
    font = dlib.options.super opt.font;
    colors = dlib.options.superRecursive opt.terminal.colors;
  };
  options.programs.foot.useTheme = mkOption {
    type = types.bool;
    default = false;
  };
  
  config =
  let
    cfg = config.programs.foot;
    theme = config.theme.foot;
  in mkIf (cfg.enable && cfg.useTheme) {
    programs.foot.settings = mkDefault {
      main = {
        font = mkIf (theme.font != null) "${theme.font.name}:size=${toString theme.font.size}"; # FIXME: handle fonts more robustly
        dpi-aware = "yes";
        bold-text-in-bright = "no";
      };
      scrollback = {
        lines = 2000;
        multiplier = 4.0;
        indicator-position = "none";
      };
      cursor = {
        style = "beam";
        blink = "no";
        color = "262626 bcbcbc";
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
