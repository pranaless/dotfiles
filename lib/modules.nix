{ self, lib }:

with lib;
{
  mkIfNotNull = v: mkIf (v != null) v;
  mkIfNotNullMap = f: v: mkIf (v != null) (f v);
}
