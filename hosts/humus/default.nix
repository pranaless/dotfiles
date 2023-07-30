{ self, nixpkgs, agenix, hyprland, ... }:
rec {
  hostName = "humus";
  system = "x86_64-linux";
  modules = [
    agenix.nixosModules.default
    ./hardware-configuration.nix
    ./users/pranaless
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
        agenix.packages.${system}.default
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

      virtualisation.docker.enable = true;

      environment.systemPackages = with pkgs; [
        brightnessctl
        grim
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
          noto-fonts
          noto-fonts-emoji
          noto-fonts-cjk-serif
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

        services.ssh-agent.enable = true;
        services.gpg-agent.enable = true;

        programs.gpg.enable = true;

        services.mako = {
          enable = true;
          font = "Cozette 10";
        };

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

              active_opacity = 0.95
              inactive_opacity = 0.85
            }

            animations {
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

            ${builtins.concatStringsSep "\n" (builtins.genList
              (i: let
                k = builtins.toString i;
                ws = if i == 0 then "10" else builtins.toString i;
              in ''
                bind = SUPER, ${k}, workspace, ${ws}
                bind = SUPER SHIFT, ${k}, movetoworkspace, ${ws}'')
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
              foreground = "cdd6f4";
              background = "1e1e2e";

              regular0 = "45475a";
              regular1 = "f38ba8";
              regular2 = "a6e3a1";
              regular3 = "f9e2af";
              regular4 = "89b4fa";
              regular5 = "f5c2e7";
              regular6 = "94e2d5";
              regular7 = "bac2de";
              bright0 = "585b70";
              bright1 = "f38ba8";
              bright2 = "a6e3a1";
              bright3 = "f9e2af";
              bright4 = "89b4fa";
              bright5 = "f5c2e7";
              bright6 = "94e2d5";
              bright7 = "a6adc8";
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
            editor = {
              line-number = "relative";
              cursor-shape = {
                insert = "bar";
                normal = "block";
              };
              bufferline = "multiple";
            };
          };
        };

        programs.imv = {
          enable = true;
        };

        programs.mpv = {
          enable = true;
        };

        programs.librewolf = {
          enable = true;
          package = pkgs.librewolf-wayland;
        };
      };

      programs.steam.enable = true;
    })
  ];
}
