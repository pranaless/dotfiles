{
  home-manager.sharedModules = [
    {
      imports = [
        ./settings
        ./programs/foot.nix
        ./programs/helix.nix
      ];
    }
  ];
}
