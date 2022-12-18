{ pkgs, lib, userModule, ... }:
userModule {
  inherit lib;
  module = { name, config, ... }:
  with lib;
  let
    cfg = config.programs.ncmpcpp;
  in {
    options.programs.ncmpcpp = {
      enable = mkEnableOption "ncmpcpp";
    };
    config = mkIf cfg.enable {
      packages = [ pkgs.ncmpcpp ];
    }
  }
}
