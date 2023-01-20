{
  home-manager.sharedModules = [
    {
      imports = [
        ./themes
        ./programs/foot.nix
      ];
    }
  ];
}
