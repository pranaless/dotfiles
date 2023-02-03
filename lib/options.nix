{ self, lib }:

with lib;
rec {
  isSetting = isType "setting";

  mkSettingOption = a: mkOption (a // {
    type = types.nullOr a.type;
    default = null;
    apply = v: {
      _type = "setting";
      self = (a.apply or (v: v)) v;
    };
  });

  inherits =
  let
    leaf = o: o // {
      default = o.value.self;
      defaultText = literalExpression (concatStringsSep "." v.loc);
      apply = v: o.apply v // {
        super = o.value.self;
      };
    };
  in opts: if isOption opts
    then leaf opts
    else mapAttrsRecursiveCond (v: ! isOption v) (_: o: leaf o) opts;

  mapSettingsSelf = mapAttrsRecursiveCond (v: ! isSetting v) (_: v: v.self);

  super = opt:
  let
    leaf = v: v // {
      default = v.value;
      defaultText = literalExpression (concatStringsSep "." v.loc);
    };
  in if isOption opt
    then leaf opt
    else mapAttrsRecursiveCond (v : ! isOption v) (_: v: leaf v) opt;
}
