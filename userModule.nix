module: { lib, ... }: {
  options.users.users = mkOption {
    type = with types; attrsOf (submodule module);
  };
}
