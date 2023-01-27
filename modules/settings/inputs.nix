{ pkgs, lib, config, options, ... }:

with lib;
{
  options.settings.inputs = {
    keyboard = {
      model = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The name of the keyboard model.";
        example = "pc105";
      };
    
      layouts = mkOption {
        type = types.listOf (types.coercedTo types.str (name: { inherit name; }) (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name of the layout.";
              example = "us";
            };
            variant = mkOption {
              type = types.nullOr types.nonEmptyStr;
              default = null;
              description = "Variant of the layout, or null for default.";
              example = "dvorak";
            };
          };
        }));
        default = [];
        description = "List of keyboard layouts.";
        example = literalExpression ''
          [
            {
              name = "us";
              variant = "dvorak";
            }
            "ua"
          ]
        '';
      };

      options = mkOption {
        type = types.listOf types.str;
        default = [];
        example = literalExpression ''[ "grp:win_space_toggle" ]'';
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

    pointer = {
      acceleration = {
        profile = mkOption {
          type = types.nullOr (types.enum [ "flat" "adaptive" ]);
          default = null;
          example = "adaptive";
        };

        value = mkOption {
          type = types.nullOr (types.numbers.between (-1.0) 1.0);
          default = null;
          example = 0.5;
        };
      };

      scroll = {
        natural = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = "Whether to enable natural scroll functionality. If active, the scroll direction is inverted.";
          example = true;
        };

        method = mkOption {
          type = types.nullOr (types.enum [ "none" "twoFinger" "edge" "button" ]);
          default = null;
          example = "twoFinger";
        };

        factor = mkOption {
          type = types.nullOr types.numbers.positive;
          default = null;
          example = 1.0;
        };

        # button = mkOption { };
      };

      leftHanded = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
      };

      disableWhileTyping = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = false;
      };

      middleButtonEmulation = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
      };

      clickMethod = mkOption {
        type = types.nullOr (types.enum [ "buttonAreas" "clickfinger" ]);
        default = null;
        example = "clickfinger";
      };

      tap = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
      };
    };

    touchpad = dl.super options.settings.inputs.pointer;

    # TODO: other per-type (see sway-input(5)) and per-device settings
  };
}