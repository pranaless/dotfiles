{ pkgs, lib, ... }:

with lib;
{
  users.users.pranaless = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]
  };
}
