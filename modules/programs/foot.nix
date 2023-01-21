{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.settings.foot = dlib.super options.settings.terminal;
  options.programs.foot.useSettings = mkOption {
    type = types.bool;
    default = false;
  };
  
  config =
  let
    cfg = config.settings.foot;
    mkIfNotNull = v: mkIf (v != null) v;
    boolSetting = b: if b then "yes" else "no";
  in mkIf (config.programs.foot.enable && config.programs.foot.useSettings) {
    programs.foot.settings = {
      main = {
        font = mkIf (cfg.font != null) "${cfg.font.name}:size=${toString cfg.font.size}"; # FIXME: handle fonts more robustly
      };
      scrollback = {
        lines = mkIfNotNull cfg.scrollback.lines;
        multiplier = mkIfNotNull cfg.scrollback.multiplier;
      };
      colors = mkMerge [
        (mkIf (cfg.colors.palette != null)
          (listToAttrs (imap0 (i: c: {
            name = if i <= 7 then "regular${toString i}" else "bright${toString (i - 8)}";
            value = c;
          }) cfg.colors.palette)))
        {
          foreground = mkIfNotNull cfg.colors.foreground;
          background = mkIfNotNull cfg.colors.background;
        }
      ];
      cursor = {
        style = mkIfNotNull cfg.cursor.shape;
        blink = mkIf (cfg.cursor.blink != null) (boolSetting cfg.cursor.blink);
      };
    };
  };
}
