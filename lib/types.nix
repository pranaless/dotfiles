{ lib }:
with lib;
{
  exactListOf = elemType: len:
    let list = types.addCheck (types.listOf elemType) (l: length l == len);
    in list // {
      description = "list of ${toString len} ${types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType}";
      emptyValue = { };
    };

  color = types.str; # TODO
}
