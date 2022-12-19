{ pkgs, lib, userModule, ... }:
{
  imports = [
    (userModule ({ name, config, ... }:
    with lib;
    let
      cfg = config.programs.ncmpcpp;
    in {
      options.programs.ncmpcpp = {
        enable = mkEnableOption "ncmpcpp";
        settings = mkOption {
          type = pkgs.formats.ini { };
        };
      };
      config = mkIf cfg.enable {
        packages = [ pkgs.ncmpcpp ];
      };
    }))
  ];
}
