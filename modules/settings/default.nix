{ lib, config, ... }:
with lib;
{
  imports = [
    ./terminal.nix
    ./foot.nix
    ./helix.nix
  ];

  options.settings = {
    font = mkOption {
      # The same as hm.types.fontType, except without the package option.
      # Since the above option is super-ed all over the place, keeping track of
      # duplicates is kinda a pain, so delegate the responsibility of adding font
      # packages to the user.
      # Maybe FIXME?
      type = types.nullOr (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            example = "DejaVu Sans";
            description = "The family name of the font.";
          };

          size = mkOption {
            type = types.nullOr types.number;
            default = null;
            example = "8";
            description = "The size of the font.";
          };
        };
      });
      default = null;
    };

    theme = mkOption {
      type = types.str;
      example = "nord";
      description = "The name of the theme, used as a file name in some places.";
    };
  };
}
