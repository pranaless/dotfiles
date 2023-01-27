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
        font = mkIf (cfg.font != null) "${cfg.font.name}:size=${toString cfg.font.size}"; # FIXME: handle fonts more robustly
      };
      scrollback = {
        lines = dl.mkIfNotNull cfg.scrollback.lines;
        multiplier = dl.mkIfNotNull cfg.scrollback.multiplier;
      };
      colors = mkMerge [
        (mkIf (cfg.colors.palette != null)
          (listToAttrs (imap0 (i: c: {
            name = if i <= 7 then "regular${toString i}" else "bright${toString (i - 8)}";
            value = formatColor c;
          }) cfg.colors.palette)))
        {
          foreground = dl.mkIfNotNullMap formatColor cfg.colors.foreground;
          background = dl.mkIfNotNullMap formatColor cfg.colors.background;
        }
        (mkIf (cfg.colors.selection != null) {
          selection-foreground = formatColor cfg.colors.selection.foreground;
          selection-background = formatColor cfg.colors.selection.background;
        })
      ];
      cursor = {
        style = dl.mkIfNotNull cfg.cursor.shape;
        blink = mkIf (cfg.cursor.blink != null) (boolSetting cfg.cursor.blink);
        color = mkIf (cfg.colors.cursor != null) "${formatColor cfg.colors.cursor.foreground} ${formatColor cfg.colors.cursor.background}";
      };
    };
  };
}
