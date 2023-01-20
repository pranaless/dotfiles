{
  home-manager.sharedModules = [
    {
      imports = [
        ./themes/font.nix
        ./themes/terminal.nix
        ./programs/foot.nix
      ];
    }
  ];
}
