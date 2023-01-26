{ pkgs, lib, dlib, config, options, ... }:

with lib;
let
  cfg = config.settings.hyprland;
  mkIfNotNull = v: mkIf (v != null) v;
  mkIfNotNullMap = f: v: mkIf (v != null) (f v);
  gradientString = v: if v ? colors
    then "${concatStringsSep " " v.colors} ${toString v.angle}deg"
    else v;
in {
  options.settings.hyprland = {
    keyboard = dlib.super options.settings.keyboard // {
      numlock = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = false;
        description = "Whether to enable numlock by default.";
      };

      repeat = {
        rate = mkOption {
          type = types.nullOr types.ints.positive;
          default = null;
          example = 25;
        };

        delay = mkOption {
          type = types.nullOr types.ints.unsigned;
          default = null;
          example = 600;
        };
      };
    };

    colors = {
      border = {
        active = mkOption {
          type = types.nullOr (types.either dlib.types.color dlib.types.linearGradient);
          default = null;
        };
        inactive = mkOption {
          type = types.nullOr (types.either dlib.types.color dlib.types.linearGradient);
          default = null;
        };
      };

      shadow = {
        active = mkOption {
          type = types.nullOr dlib.types.color;
          default = null;
        };
        inactive = mkOption {
          type = types.nullOr dlib.types.color;
          default = null;
        };
      };
    };
  };
  options.programs.hyprland.useSettings = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.programs.hyprland.useSettings {
    programs.hyprland.settings = {
      input = {
        kb_model = mkIfNotNull cfg.keyboard.model;
        kb_layout = mkIf (cfg.keyboard.layouts != [])
          (concatStringsSep "," (map (v: v.name) cfg.keyboard.layouts));
        kb_variant = mkIf (any (v: v.variant != null) cfg.keyboard.layouts)
          (concatStringsSep "," (map (v: v.variant) cfg.keyboard.layouts));
        kb_options = mkIfNotNullMap (concatStringsSep ",") cfg.keyboard.options;

        numlock_by_default = mkIfNotNull cfg.keyboard.numlock;
        repeat_rate = mkIfNotNull cfg.keyboard.repeat.rate;
        repeat_delay = mkIfNotNull cfg.keyboard.repeat.delay;
      };
      general = {
        "col.active_border" = mkIfNotNullMap gradientString cfg.colors.border.active;
        "col.inactive_border" = mkIfNotNullMap gradientString cfg.colors.border.inactive;
      };
    };
  };
}
