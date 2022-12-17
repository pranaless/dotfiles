{ ... }:

{
  users.users.humus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  home-manager.users.humus = { config, pkgs, ... }: {
    home.stateVersion = "22.05";

    imports = [ ../../modules ];
    home.packages = with pkgs; [
      bc
      brightnessctl
      cozette
      fd
      fira-code
      eww-wayland
      git
      grim
      helix
      imv
      librewolf-wayland
      mpd
      pavucontrol
      ripgrep
      river
      slurp
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false;
      })
      wl-clipboard
    ];
    
    home.pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
    };
    fonts.fontconfig.enable = true;
    
    services.syncthing.enable = true;
    
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
    
    xdg = {
      enable = true;
    };
    
    modules.foot.enable = true;
    # modules.git.enable = true;
  };
}
