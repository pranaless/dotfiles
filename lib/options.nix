{ lib }:

with lib;
rec {
  super = opt: opt // {
    default = opt.value;
  };

  superRecursive = mapAttrsRecursiveCond (v : ! isOption v) (_: v: super v);
}
