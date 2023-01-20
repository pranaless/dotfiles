{
  home-manager.sharedModules = [
    {
      imports = [
        ./themes
        ./programs/foot.nix
        ./programs/helix.nix
      ];
    }
  ];
}
