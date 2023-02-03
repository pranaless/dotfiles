{ pkgs, lib, config, options, ... }:

with lib;
let
  cfg = config.settings.foot;
  formatColor = dl.colors.formatAsHex false;
  boolSetting = b: if b then "yes" else "no";
in {
  options.settings.foot = dl.inherits options.settings.terminal;
  options.programs.foot.useSettings = mkOption {
    type = types.bool;
    default = false;
  };
  
  config = mkIf (config.programs.foot.enable && config.programs.foot.useSettings) {
    programs.foot.settings = {
      main = {
        font = dl.mkSettingMap (f: "${f.name}:size=${toString f.size}") cfg.font; # FIXME: handle fonts more robustly
      };
      scrollback = {
        lines = dl.mkSetting cfg.scrollback.lines;
        multiplier = dl.mkSetting cfg.scrollback.multiplier;
      };
      colors = mkMerge [
        (dl.mkSettingMap (v: listToAttrs (imap0 (i: c: {
          name = if i <= 7 then "regular${toString i}" else "bright${toString (i - 8)}";
          value = formatColor c;
        }) v)) cfg.colors.palette)
        {
          foreground = dl.mkSettingMap formatColor cfg.colors.foreground;
          background = dl.mkSettingMap formatColor cfg.colors.background;
        }
        (dl.mkSettingMap (v: {
          selection-foreground = formatColor v.foreground;
          selection-background = formatColor v.background;
        }) cfg.colors.selection)
      ];
      cursor = {
        style = dl.mkSetting cfg.cursor.shape;
        blink = dl.mkSettingMap boolSetting cfg.cursor.blink;
        color = dl.mkSettingMap (v: "${formatColor v.foreground} ${formatColor v.background}") cfg.colors.cursor;
      };
    };
  };
}
