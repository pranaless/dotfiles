{ pkgs, lib, config, options, ... }:

with lib;
let
  cfg = config.settings.hyprland;
  formatColor = c: "rgba(${dl.colors.formatAsHex true c})";
  gradientString = v: if v ? colors
    then "${concatStringsSep " " (map formatColor v.colors)} ${toString v.angle}deg"
    else formatColor v;
in {
  options.settings.hyprland = {
    inputs = recursiveUpdate (dl.super options.settings.inputs) {
      keyboard = {
        numlock = mkOption {
          type = types.nullOr types.bool;
          default = null;
          example = false;
          description = "Whether to enable numlock by default.";
        };
      };
    };

    colors = {
      border = {
        active = mkOption {
          type = types.nullOr (types.either dl.types.color dl.types.linearGradient);
          default = null;
        };
        inactive = mkOption {
          type = types.nullOr (types.either dl.types.color dl.types.linearGradient);
          default = null;
        };
      };

      shadow = {
        active = mkOption {
          type = types.nullOr dl.types.color;
          default = null;
        };
        inactive = mkOption {
          type = types.nullOr dl.types.color;
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
      input =
      let
        kb = cfg.inputs.keyboard;
        pt = cfg.inputs.pointer;
        tp = cfg.inputs.touchpad;
      in {
        kb_model = dl.mkIfNotNull kb.model;
        kb_layout = mkIf (kb.layouts != [])
          (concatStringsSep "," (map (v: v.name) kb.layouts));
        kb_variant = mkIf (any (v: v.variant != null) kb.layouts)
          (concatStringsSep "," (map (v: v.variant) kb.layouts));
        kb_options = dl.mkIfNotNullMap (concatStringsSep ",") kb.options;

        repeat_rate = dl.mkIfNotNull kb.repeat.rate;
        repeat_delay = dl.mkIfNotNull kb.repeat.delay;

        numlock_by_default = dl.mkIfNotNull kb.numlock;

        sensitivity = dl.mkIfNotNull pt.acceleration.value;
        accel_profile = dl.mkIfNotNull pt.acceleration.profile;

        left_handed = dl.mkIfNotNull pt.leftHanded;
        scroll_method = dl.mkIfNotNullMap (v: {
          none = "no_scroll";
          twoFinger = "2fg";
          edge = "edge";
          button = "on_button_down";
        }.${v}) pt.scroll.method;
        natural_scroll = dl.mkIfNotNull pt.scroll.natural;

        touchpad = {
          disable_while_typing = dl.mkIfNotNull tp.disableWhileTyping;
          natural_scroll = dl.mkIfNotNull tp.scroll.natural;
          scroll_factor = dl.mkIfNotNull tp.scroll.factor;
          middle_button_emulation = dl.mkIfNotNull tp.middleButtonEmulation;
          clickfinger_behavior = dl.mkIfNotNullMap (v: {
            buttonAreas = false;
            clickfinger = true;
          }.${v}) tp.clickMethod;
          tap-to-click = dl.mkIfNotNull tp.tap;
        };
      };
      decoration = {
        "col.shadow" = dl.mkIfNotNullMap gradientString cfg.colors.shadow.active;
        "col.shadow_inactive" = dl.mkIfNotNullMap gradientString cfg.colors.shadow.inactive;
      };
      general = {
        "col.active_border" = dl.mkIfNotNullMap gradientString cfg.colors.border.active;
        "col.inactive_border" = dl.mkIfNotNullMap gradientString cfg.colors.border.inactive;
      };
    };
  };
}
