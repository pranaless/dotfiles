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
      terminal = {
        font = {
          name = "Cozette";
          size = 10;
        };
        colors = {
          palette = [
            "1c1c1c"
            "af5f5f"
            "5f875f"
            "87875f"
            "5f87af"
            "5f5f87"
            "5f8787"
            "6c6c6c"
            "444444"
            "ff8700"
            "87af87"
            "ffffaf"
            "87afd7"
            "8787af"
            "5fafaf"
            "ffffff"
          ];
          foreground = "bcbcbc";
          background = "262626";
        };
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
    programs.ncmpcpp = {
      enable = true;
      settings = {
        user_interface = "alternative";
      };
    };

    xdg = {
      enable = true;
    };

    programs.foot = {
      enable = true;
      useTheme = true;
    };
    
    # modules.git.enable = true;
  };
}
