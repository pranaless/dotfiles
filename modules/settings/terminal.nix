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
    font = dl.inherits options.settings.font;
  
    colors = {
      palette = dl.mkSettingOption {
        type = dl.types.lists.exact dl.types.color 16;
      };

      foreground = dl.mkSettingOption {
        type = dl.types.color;
      };
      background = dl.mkSettingOption {
        type = dl.types.color;
      };

      selection = dl.mkSettingOption {
        type = colors;
      };

      cursor = dl.mkSettingOption {
        type = colors;
      };
    };

    scrollback = {
      lines = dl.mkSettingOption {
        type = types.ints.unsigned;
      };
      multiplier = dl.mkSettingOption {
        type = types.numbers.positive;
      };
    };

    cursor = {
      shape = dl.mkSettingOption {
        type = types.enum [ "block" "beam" "underline" ];
      };
      blink = dl.mkSettingOption {
        type = types.bool;
      };
    };
  };
}
