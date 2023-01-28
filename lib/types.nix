{ self, lib }:
with lib;
rec {
  # Actually good uniq that respects the merge behaviour of the type it wraps.
  uniq = elemType: mkOptionType {
    name = "uniq";
    inherit (elemType) description descriptionClass check emptyValue getSubOptions getSubModules;
    merge = loc: defs:
      if length defs == 1
        then elemType.merge loc defs
        else assert length defs > 1;
          throw "The option `${showOption loc}' is defined multiple times. Definition values:${showDefs defs}";
    substSubModules = m: uniq (elemType.substSubModules m);
    functor = (defaultFunctor "uniq") // { wrapped = elemType; };
    nestedTypes.elemType = elemType;
  };

  lists = {
    atLeast = elemType: len:
      let list = types.addCheck (types.listOf elemType) (l: length l >= len);
      in list // {
        description = "list of at-least ${toString len} ${types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType}";
        emptyValue = { };
      };

    exact = elemType: len:
      let list = uniq (types.addCheck (types.listOf elemType) (l: length l == len));
      in list // {
        description = "list of ${toString len} ${types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType}";
        emptyValue = { };
      };
  };

  color = mkOptionType {
    name = "colorString";
    description = "css rgb color string";
    descriptionClass = "noun";
    check = x: isString x && self.colors.parseColor x != null;
    merge = loc: defs: mergeEqualOption loc (map (def: def // { value = "#${self.colors.formatAsHex true def.value}"; }) defs);
  };

  linearGradient = types.submodule ({ config, ... }: {
    options = {
      colors = mkOption {
        type = uniq (lists.atLeast color 2);
      };
      angle = mkOption {
        type = types.number;
      };
    };
  }) // {
    description = "linear gradient";
  };
}
