{
  home-manager.sharedModules = [
    {
      imports = [
        ./themes/font.nix
        ./programs/foot.nix
      ];
    }
  ];
}
