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
  toKeyValue =
    let
      mkKeyValue = generators.mkKeyValueDefault { } "=";
      mkLine = k: v: mkKeyValue k v + "\n";
      mkLines = { name, value }: map (mkLine name) (toList value);
    in pair: concatStrings (mkLines pair);
  generateConfig = attrs:
    let
      stripName = name:
        map (flip nameValuePair attrs.${name}) (builtins.match "_*(.+)" name);
      section = { name, value }: "${name} {\n${generateConfig value}}\n";
      sectionOrVariable = pair: if isAttrs pair.value then section pair else toKeyValue pair;
    in concatStrings (map sectionOrVariable (concatMap stripName (attrNames attrs)));
in {
  options.programs.hyprland = {
    enable = mkEnableOption "hyprland";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.hyprland;
      defaultText = literalExpression "pkgs.hyprland";
      description = "The hyprland package to install.";
      example = literalExpression ''
        pkgs.hyprland.override {
          nvidiaPatches = true;
        }
      '';
    };

    settings = mkOption {
      type = configType;
      default = { };
      description = ''
        Configuration written to <filename>$XDG_CONFIG_HOME/hypr/hyprland.conf</filename>.

        Similar to the INI format: sets are converted to categories, lists are expanded as duplicate keys,
        with one notable exception. Attributes that start with an underscore are placed before other attributes,
        with the underscore removed.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];
  
    xdg.configFile."hypr/hyprland.conf" = mkIf (cfg.settings != { }) {
      text = generateConfig cfg.settings;
    };
  };
}
