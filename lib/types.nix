{ lib }:
with lib;
rec {
  lists = {
    atLeast = elemType: len:
      let list = types.addCheck (types.listOf elemType) (l: length l >= len);
      in list // {
        description = "list of at-least ${toString len} ${types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType}";
        emptyValue = { };
      };

    exact = elemType: len:
      let list = types.uniq (types.addCheck (types.listOf elemType) (l: length l == len));
      in list // {
        description = "list of ${toString len} ${types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType}";
        emptyValue = { };
      };
  };

  color = types.str // {
    name = "color";
  }; # TODO

  linearGradient = types.submodule ({ config, ... }: {
    options = {
      colors = mkOption {
        type = types.uniq (lists.atLeast color 2);
      };
      angle = mkOption {
        type = types.number;
      };
    };
  });
}
