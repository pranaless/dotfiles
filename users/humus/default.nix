{ pkgs, config, ... }:

{
  # hardware.bluetooth = {
  #   enable = true;
  #   settings = {
  #     General.Enable = "Source,Sink,Media,Socket";
  #   };
  # };

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
      keepassxc
      librewolf-wayland
      mpv
      pavucontrol
      ripgrep
      # river
      slurp
      swww
      wf-recorder
      wl-clipboard
      wlsunset
      zathura
    ];
    
    settings = {
      theme = "kanagawa";
    
      inputs = {
        keyboard = {
          layouts = [ "us" "de" "ua" "ru" ];
          options = [ "grp:win_space_toggle" ];
        };
        pointer = {
          disableWhileTyping = false;
          clickMethod = "clickfinger";
        };
        touchpad = {
          scroll.natural = true;
        };
      };
    
      terminal = {
        font = {
          name = "Cozette";
          size = 10;
        };
        colors = {
          palette = [
            "#090618"
            "#c34043"
            "#76946a"
            "#c0a36e"
            "#7e9cd8"
            "#957fb8"
            "#6a9589"
            "#c8c093"
            "#727169"
            "#e82424"
            "#98bb6c"
            "#e6c384"
            "#7fb4ca"
            "#938aa9"
            "#7aa89f"
            "#dcd7ba"
          ];
          foreground = "#dcd7ba";
          background = "#1f1f28";

          selection = {
            foreground = "#c8c093";
            background = "#2d4f67";
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

      hyprland = {
        colors.border = {
          active = {
            colors = [ "#7e9cd8ee" "#7fb4caee" ];
            angle = 45;
          };
          inactive = "#595959aa";
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
      settings = {
        theme = "catppuccin_mocha";
        editor.line-number = "relative";
        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
        };
      };
    };

    programs.hyprland = {
      enable = true;
      useSettings = true;
      settings = {
        monitor = [
          ",preferred,auto,auto"
        ];

        exec-once = [
          "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "${pkgs.swww}/bin/swww init"
          "${pkgs.foot}/bin/foot --server"
          "${pkgs.eww-wayland}/bin/eww open bar"
        ];

        input = {
          follow_mouse = 1;
        };

        general = {
          gaps_in = 10;
          gaps_out = 20;

          border_size = 2;

          no_cursor_warps = true;
          cursor_inactive_timeout = 5;

          layout = "dwindle";
        };

        decoration = {
          rounding = 10;

          blur = true;
          blur_size = 3;
          blur_passes = 4;
          blur_ignore_opacity = true;

          active_opacity = 0.8;
          inactive_opacity = 0.6;

          drop_shadow = false;
        };

        animations = {
          enabled = true;

          _bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        gestures = {
          workspace_swipe = true;
        };

        bind = let mod = "SUPER"; in [
          "${mod}, Return, exec, ${pkgs.foot}/bin/footclient"

          "${mod} SHIFT, Q, exit,"

          "${mod}, C, killactive,"
          "${mod}, D, togglefloating,"
          "${mod}, F, fullscreen, 0"
          "${mod}, P, pseudo,"
          "${mod}, S, togglesplit,"
          
          "${mod}, left,  movefocus, l"
          "${mod}, right, movefocus, r"
          "${mod}, up,    movefocus, u"
          "${mod}, down,  movefocus, d"

          "${mod}, 1, workspace, 1"
          "${mod}, 2, workspace, 2"
          "${mod}, 3, workspace, 3"
          "${mod}, 4, workspace, 4"
          "${mod}, 5, workspace, 5"
          "${mod}, 6, workspace, 6"
          "${mod}, 7, workspace, 7"
          "${mod}, 8, workspace, 8"
          "${mod}, 9, workspace, 9"
          "${mod}, 0, workspace, 10"

          "${mod} SHIFT, 1, movetoworkspace, 1"
          "${mod} SHIFT, 2, movetoworkspace, 2"
          "${mod} SHIFT, 3, movetoworkspace, 3"
          "${mod} SHIFT, 4, movetoworkspace, 4"
          "${mod} SHIFT, 5, movetoworkspace, 5"
          "${mod} SHIFT, 6, movetoworkspace, 6"
          "${mod} SHIFT, 7, movetoworkspace, 7"
          "${mod} SHIFT, 8, movetoworkspace, 8"
          "${mod} SHIFT, 9, movetoworkspace, 9"
          "${mod} SHIFT, 0, movetoworkspace, 10"
        ];

        bindm = let mod = "SUPER"; in [
          "${mod}, mouse:272, movewindow"
          "${mod}, mouse:273, resizewindow"
        ];
      };
    };

    services.mako = {
      enable = true;
      font = "Cozette 10";
    };
  };
}
