{ self, lib }:

with lib;
rec {
  mkIfNotNull = mkIfNotNullMap (v: v);
  mkIfNotNullMap = f: v: mkIf (v != null) (f v);
}
