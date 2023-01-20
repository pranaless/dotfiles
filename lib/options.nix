{ lib }:

with lib;
rec {
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
