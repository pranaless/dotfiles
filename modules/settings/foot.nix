{ pkgs, lib, config, options, ... }:

with lib;
let
  cfg = config.settings.foot;
  formatColor = dl.colors.formatAsHex false;
  boolSetting = b: if b then "yes" else "no";
in {
  options.settings.foot = dl.super options.settings.terminal;
  options.programs.foot.useSettings = mkOption {
    type = types.bool;
    default = false;
  };
  
  config = mkIf (config.programs.foot.enable && config.programs.foot.useSettings) {
    programs.foot.settings = {
      main = {
        font = dl.mkIfNotNullMap (v: "${v.name}:size=${toString v.size}") cfg.font; # FIXME: handle fonts more robustly
      };
      scrollback = {
        lines = dl.mkIfNotNull cfg.scrollback.lines;
        multiplier = dl.mkIfNotNull cfg.scrollback.multiplier;
      };
      colors = mkMerge [
        (dl.mkIfNotNullMap (v: listToAttrs (imap0 (i: c: {
            name = if i <= 7 then "regular${toString i}" else "bright${toString (i - 8)}";
            value = formatColor c;
          }) v)) cfg.colors.palette)
        {
          foreground = dl.mkIfNotNullMap formatColor cfg.colors.foreground;
          background = dl.mkIfNotNullMap formatColor cfg.colors.background;
        }
        (dl.mkIfNotNullMap (v: {
          selection-foreground = formatColor v.foreground;
          selection-background = formatColor v.background;
        }) cfg.colors.selection)
      ];
      cursor = {
        style = dl.mkIfNotNull cfg.cursor.shape;
        blink = dl.mkIfNotNullMap boolSetting cfg.cursor.blink;
        color = dl.mkIfNotNullMap (v: "${formatColor v.foreground} ${formatColor v.background}") cfg.colors.cursor;
      };
    };
  };
}
