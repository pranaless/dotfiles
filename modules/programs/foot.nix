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
    mkIfNotNull = v: mkIf (v != null) v;
  in mkIf (cfg.enable && cfg.useTheme) {
    programs.foot.settings = {
      main = {
        font = mkIf (theme.font != null) "${theme.font.name}:size=${toString theme.font.size}"; # FIXME: handle fonts more robustly
      };
      scrollback = let cfg = theme.scrollback;
      in {
        lines = mkIfNotNull cfg.lines;
        multiplier = mkIfNotNull cfg.multiplier;
      };
      colors = let cfg = theme.colors;
      in mkMerge [
        (mkIf (cfg.palette != null)
          (listToAttrs (imap0 (i: c: {
            name = if i <= 7 then "regular${toString i}" else "bright${toString (i - 8)}";
            value = c;
          }) cfg.palette)))
        {
          foreground = mkIfNotNull cfg.foreground;
          background = mkIfNotNull cfg.background;
        }
      ];
    };
  };
}
