{ pkgs, lib, dlib, config, options, ... }:

with lib;
let
  cfg = config.settings.hyprland;
  mkIfNotNull = v: mkIf (v != null) v;
  mkIfNotNullMap = f: v: mkIf (v != null) (f v);
  formatColor = c:
    let color = dlib.colors.parseColor c;
    in "rgba(${toHexString color.red}${toHexString color.green}${toHexString color.blue}${toHexString color.alpha})";
  gradientString = v: if v ? colors
    then "${concatStringsSep " " (map formatColor v.colors)} ${toString v.angle}deg"
    else formatColor v;
in {
  options.settings.hyprland = {
    inputs = recursiveUpdate (dlib.super options.settings.inputs) {
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
      input =
      let
        kb = cfg.inputs.keyboard;
        pt = cfg.inputs.pointer;
        tp = cfg.inputs.touchpad;
      in {
        kb_model = mkIfNotNull kb.model;
        kb_layout = mkIf (kb.layouts != [])
          (concatStringsSep "," (map (v: v.name) kb.layouts));
        kb_variant = mkIf (any (v: v.variant != null) kb.layouts)
          (concatStringsSep "," (map (v: v.variant) kb.layouts));
        kb_options = mkIfNotNullMap (concatStringsSep ",") kb.options;

        repeat_rate = mkIfNotNull kb.repeat.rate;
        repeat_delay = mkIfNotNull kb.repeat.delay;

        numlock_by_default = mkIfNotNull kb.numlock;

        sensitivity = mkIfNotNull pt.acceleration.value;
        accel_profile = mkIfNotNull pt.acceleration.profile;

        left_handed = mkIfNotNull pt.leftHanded;
        scroll_method = mkIfNotNullMap (v: {
          none = "no_scroll";
          twoFinger = "2fg";
          edge = "edge";
          button = "on_button_down";
        }.${v}) pt.scroll.method;
        natural_scroll = mkIfNotNull pt.scroll.natural;

        touchpad = {
          disable_while_typing = mkIfNotNull tp.disableWhileTyping;
          natural_scroll = mkIfNotNull tp.scroll.natural;
          scroll_factor = mkIfNotNull tp.scroll.factor;
          middle_button_emulation = mkIfNotNull tp.middleButtonEmulation;
          clickfinger_behavior = mkIfNotNullMap (v: {
            buttonAreas = false;
            clickfinger = true;
          }.${v}) tp.clickMethod;
          tap-to-click = mkIfNotNull tp.tap;
        };
      };
      decoration = {
        "col.shadow" = mkIfNotNullMap gradientString cfg.colors.shadow.active;
        "col.shadow_inactive" = mkIfNotNullMap gradientString cfg.colors.shadow.inactive;
      };
      general = {
        "col.active_border" = mkIfNotNullMap gradientString cfg.colors.border.active;
        "col.inactive_border" = mkIfNotNullMap gradientString cfg.colors.border.inactive;
      };
    };
  };
}
