{ pkgs, lib, dlib, config, options, ... }:

with lib;
{
  options.settings.terminal = {
    font = dlib.super options.settings.font;
  
    colors = {
      palette = mkOption {
        type = types.nullOr (types.uniq (dlib.types.exactListOf dlib.types.color 16));
        default = null;
      };

      foreground = mkOption {
        type = types.nullOr dlib.types.color;
        default = null;
      };
      background = mkOption {
        type = types.nullOr dlib.types.color;
        default = null;
      };
    };

    scrollback = {
      lines = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      multiplier = mkOption {
        type = types.nullOr types.number;
        default = null;
      };
    };

    cursor = {
      shape = mkOption {
        type = types.nullOr (types.enum [ "block" "beam" "underline" ]);
        default = null;
      };
      blink = mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
    };
  };
}
