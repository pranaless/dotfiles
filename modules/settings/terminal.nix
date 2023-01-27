{ pkgs, lib, config, options, ... }:

with lib;
let
  colors = types.submodule {
    options = {
      foreground = mkOption {
        type = dl.types.color;
      };

      background = mkOption {
        type = dl.types.color;
      };
    };
  };
in {
  options.settings.terminal = {
    font = dl.super options.settings.font;
  
    colors = {
      palette = mkOption {
        type = types.nullOr (dl.types.lists.exact dl.types.color 16);
        default = null;
      };

      foreground = mkOption {
        type = types.nullOr dl.types.color;
        default = null;
      };
      background = mkOption {
        type = types.nullOr dl.types.color;
        default = null;
      };

      selection = mkOption {
        type = types.nullOr colors;
        default = null;
      };

      cursor = mkOption {
        type = types.nullOr colors;
        default = null;
      };
    };

    scrollback = {
      lines = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
      };
      multiplier = mkOption {
        type = types.nullOr types.numbers.positive;
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
