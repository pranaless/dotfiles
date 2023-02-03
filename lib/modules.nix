{ self, lib }:

with lib;
rec {
  mkIfNotNull = mkIfNotNullMap (v: v);
  mkIfNotNullMap = f: v: mkIf (v != null) (f v);

  mkSetting = mkSettingMap (v: v);
  mkSettingMap = f: v: mkIfNotNullMap f v.self;

  mkDistinctSetting = mkDistinctSetting (v: v);
  mkDistinctSettingMap = f: v: mkIf (v.self != null && v.self != v.super) (f v);
}
