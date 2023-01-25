{
  home-manager.sharedModules = [
    {
      imports = [
        ./settings
        ./programs/hyprland.nix
      ];
    }
  ];
}
