{ pkgs, lib, dlib, config, options, ... }:

with lib;
let
  defaultColors = {
    foreground = mkOption {
      type = types.nullOr dlib.types.color;
      default = null;
    };
    background = mkOption {
      type = types.nullOr dlib.types.color;
      default = null;
    };
  };
in {
  options.theme.terminal = {
    font = dlib.super options.theme.font;
  
    colors = {
      palette = mkOption {
        type = types.nullOr (types.uniq (dlib.types.exactListOf dlib.types.color 16));
        default = null;
      };
    } // defaultColors;
  };
}
