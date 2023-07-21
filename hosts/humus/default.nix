{ self, nixpkgs, hyprland, ... }:
{
  hostName = "humus";
  system = "x86_64-linux";
  modules = [
    ./hardware-configuration.nix
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "osu-lazer"
        "steam"
      ];
      system.stateVersion = "22.05";
    }
    ({ pkgs, ... }: {
      # Not sure if this actually helps?
      boot.initrd.availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];

      environment.systemPackages = with pkgs; [
        btrfs-progs
      ];

      time.timeZone = "UTC";
      i18n.defaultLocale = "en_US.UTF-8";
    })
    ({ pkgs, ... }: {
      networking.networkmanager.enable = true;

      networking.firewall.allowedTCPPorts = [ 25565 ];

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

      services.printing = {
        enable = true;
        drivers = [ pkgs.brlaser ];
      };

      services.openssh = {
        enable = true;
      };
      programs.ssh = {
        startAgent = true;
      };

      environment.systemPackages = with pkgs; [
        brightnessctl
        grim
        imv
        mpv
        pavucontrol
        slurp
        wf-recorder
        wl-clipboard
        yt-dlp
      ];

      users.users.humus = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };

      home-manager.users.humus = { config, pkgs, ... }: {
        imports = [
          hyprland.homeManagerModules.default
        ];

        home.stateVersion = "22.05";

        home.packages = with pkgs; [
          cozette
          fira-code
          eww-wayland
          keepassxc
          librewolf-wayland
          noto-fonts
          swww
          wlsunset
          zathura
        ];

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

        wayland.windowManager.hyprland = {
          enable = true;
          extraConfig = ''
            general {
              gaps_in = 10
              gaps_out = 20
              border_size = 2
              col.active_border = rgba(7E9CD8EE) rgba(7FB4CAEE) 45deg
              col.inactive_border = rgba(595959AA)

              no_cursor_warps = true
              cursor_inactive_timeout = 5

              layout = dwindle
            }

            decoration {
              rounding = 10

              drop_shadow = false

              blur = true
              blur_size = 3
              blur_passes = 4
              blur_ignore_opacity = true

              active_opacity = 0.8
              inactive_opacity = 0.6
            }

            animations {
              enable = true

              bezier = myBezier, 0.05, 0.9, 0.1, 1.05
              animation = windows, 1, 7, myBezier
              animation = windowsOut, 1, 7, default, popin 80%
              animation = border, 1, 10, default
              animation = fade, 1, 7, default
              animation = workspaces, 1, 6, default
            }

            input {
              kb_layout = us,de,ua,ru
              kb_options = grp:win_space_toggle
              follow_mouse = 2
              touchpad {
                clickfinger_behavior = true
                disable_while_typing = false
                natural_scroll = true
              }
            }

            dwindle {
              pseudotile = true
              preserve_split = true
            }

            monitor = ,preferred,auto,auto

            exec-once = ${pkgs.swww}/bin/swww init
            exec-once = ${pkgs.foot}/bin/foot --server
            exec-once = ${pkgs.eww-wayland}/bin/eww open bar

            bind = SUPER, Return, exec, ${pkgs.foot}/bin/footclient

            bind = SUPER SHIFT, Q, exit,

            bind = SUPER, C, killactive,
            bind = SUPER, D, togglefloating,
            bind = SUPER, F, fullscreen, 0
            bind = SUPER, P, pseudo,
            bind = SUPER, S, togglesplit,

            bind = SUPER, left,  movefocus, l
            bind = SUPER, right, movefocus, r
            bind = SUPER, up,    movefocus, u
            bind = SUPER, down,  movefocus, d

            ${builtins.concatStringsSep "" (builtins.genList
              (i: let
                k = builtins.toString i;
                ws = if i == 0 then "10" else builtins.toString i;
              in ''
                bind = SUPER, ${k}, workspace, ${ws}
                bind = SUPER SHIFT, ${k}, movetoworkspace, ${ws}
              '')
              10)}
            bindm = SUPER, mouse:272, movewindow
            bindm = SUPER, mouse:273, resizewindow
          '';
        };

        programs.foot = {
          enable = true;
          settings = {
            main = {
              bold-text-in-bright = "no";
              dpi-aware = "yes";
              font = "Cozette:size=10";
            };
            colors = {
              foreground = "dcd7ba";
              background = "1f1f28";

              selection-foreground = "c8c093";
              selection-background = "2d4f67";

              regular0 = "090618";
              regular1 = "c34043";
              regular2 = "76946a";
              regular3 = "c0a36e";
              regular4 = "7e9cd8";
              regular5 = "957fb8";
              regular6 = "6a9589";
              regular7 = "c8c093";
              bright0 = "727169";
              bright1 = "e82424";
              bright2 = "98bb6c";
              bright3 = "e6c384";
              bright4 = "7fb4ca";
              bright5 = "938aa9";
              bright6 = "7aa89f";
              bright7 = "dcd7ba";
            };
            cursor = {
              blink = "no";
              style = "beam";
            };
            scrollback = {
              indicator-position = "none";
              lines = 2000;
              multiplier = 4;
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

        services.mako = {
          enable = true;
          font = "Cozette 10";
        };
      };

      programs.steam.enable = true;
    })
  ];
}
