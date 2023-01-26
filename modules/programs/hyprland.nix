{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.programs.hyprland;
  configType = with types; oneOf [
    bool
    int
    float
    str
    (attrsOf configType)
    (listOf configType)
  ];
  generateConfig = attrs:
    let
      leaves = generators.toKeyValue { listsAsDuplicateKeys = true; }
        (filterAttrs (_: v: ! builtins.isAttrs v) attrs);
      section = name: value: "${name} {\n${generateConfig value}}\n";
      branches = concatStrings (mapAttrsToList section
        (filterAttrs (_: v: builtins.isAttrs v) attrs));
    in leaves + branches;
in {
  options.programs.hyprland = {
    enable = mkEnableOption "hyprland";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.hyprland.hyprland;
      defaultText = literalExpression "pkgs.hyprland.hyprland";
      description = "The hyprland package to install.";
      example = literalExpression ''
        pkgs.hyprland.hyprland.override {
          nvidiaPatches = true;
        }
      '';
    };

    settings = mkOption {
      type = configType;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];
  
    xdg.configFile."hypr/hyprland.conf" = mkIf (cfg.settings != { }) {
      text =
        if cfg.settings ? animations
          then
            let
              animations = removeAttrs cfg.settings.animations [ "bezier" ];
              bezier = generateConfig {
                bezier = optional (cfg.settings.animations ? bezier) cfg.settings.animations.bezier;
              };
              IHateHyprlandConfigurationFileAndItHatesMe = removeAttrs cfg.settings [ "animations" ];
            in generateConfig IHateHyprlandConfigurationFileAndItHatesMe + "animations {\n${bezier}${generateConfig animations}}\n"
          else generateConfig cfg.settings;
    };
  };
}
