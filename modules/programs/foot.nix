{ pkgs, lib, dlib, config, ... }:

with lib;
{
  options.theme.foot = 
  let cfg = config.theme;
  in {
    font = mkOption {
      type = types.nullOr hm.types.fontType;
      default = cfg.font;
    };
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
      colors = {
        foreground = "bcbcbc";
        background = "262626";
        regular0 = "1c1c1c";
        regular1 = "af5f5f";
        regular2 = "5f875f";
        regular3 = "87875f";
        regular4 = "5f87af";
        regular5 = "5f5f87";
        regular6 = "5f8787";
        regular7 = "6c6c6c";
        bright0 = "444444";
        bright1 = "ff8700";
        bright2 = "87af87";
        bright3 = "ffffaf";
        bright4 = "87afd7";
        bright5 = "8787af";
        bright6 = "5fafaf";
        bright7 = "ffffff";
      };
    };
  };
}
