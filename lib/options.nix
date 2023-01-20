{ lib }:

with lib;
rec {
  super = opt:
  let
    leaf = v: v // {
      default = v.value;
    };
  in if isOption opt
    then leaf opt
    else mapAttrsRecursiveCond (v : ! isOption v) (_: v: super v) opt;
}
