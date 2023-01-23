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
      imv
      librewolf-wayland
      pavucontrol
      ripgrep
      river
      slurp
      swww
      (tor-browser-bundle-bin.override {
        useHardenedMalloc = false;
      })
      wl-clipboard
      wlsunset
    ];
    
    settings = {
      theme = "kanagawa";
    
      terminal = {
        font = {
          name = "Cozette";
          size = 10;
        };
        colors = {
          palette = [
            "090618"
            "c34043"
            "76946a"
            "c0a36e"
            "7e9cd8"
            "957fb8"
            "6a9589"
            "c8c093"
            "727169"
            "e82424"
            "98bb6c"
            "e6c384"
            "7fb4ca"
            "938aa9"
            "7aa89f"
            "dcd7ba"
          ];
          foreground = "dcd7ba";
          background = "1f1f28";

          selection = {
            foreground = "c8c093";
            background = "2d4f67";
          };
        };
        scrollback = {
          lines = 2000;
          multiplier = 4.0;
        };
        cursor = {
          shape = "beam";
          blink = false;
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
      useSettings = true;
      settings = {
        main = {
          dpi-aware = "yes";
          bold-text-in-bright = "no";
        };
        scrollback = {
          indicator-position = "none";
        };
      };
    };

    programs.helix = {
      enable = true;
      useSettings = true;
      settings = {
        editor.line-number = "relative";
        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
        };
      };
    };
  };
}
