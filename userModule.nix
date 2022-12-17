{ module, lib, ... }: 
with lib;
{
  options.users.users = mkOption {
    type = with types; attrsOf (submodule module);
  };
}
