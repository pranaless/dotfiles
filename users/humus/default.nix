{ pkgs, config, ... }:

{
  hardware.bluetooth = {
    enable = true;
    settings = {
      General.Enable = "Source,Sink,Media,Socket";
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  users.users.humus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  home-manager.users.humus = { config, pkgs, ... }: {
    home.stateVersion = "22.05";

    home.packages = with pkgs; [
      bc
      brightnessctl
      cozette
      fd
      fira-code
      eww-wayland
      foot
      git
      grim
      helix
      imv
      librewolf-wayland
      pavucontrol
      ripgrep
      river
      slurp
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false;
      })
      wl-clipboard
    ];
    
    theme = {
      font = {
        package = pkgs.cozette;
        name = "Cozette";
        size = 10;
      };
    };

    home.pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
    };
    fonts.fontconfig.enable = true;
    
    services.syncthing.enable = true;
    
    programs.gpg.enable = true;
    services.gpg-agent.enable = true;
    
    services.mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/@music";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "My PipeWire Output"
        }
      '';
    };
    programs.ncmpcpp.enable = true;

    xdg = {
      enable = true;
    };
    
    # modules.foot.enable = true;
    # modules.git.enable = true;
  };
}
