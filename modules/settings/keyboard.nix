{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.settings.keyboard = {
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
  };
}