{ self, nixpkgs, hyprland, ... }:
{
  hostName = "humus";
  system = "x86_64-linux";
  modules = [
    hyprland.nixosModules.default
    ../../users/humus
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "osu-lazer"
        "steam"
      ];
      system.stateVersion = "22.05";
    }
    ({ pkgs, ... }: {
      imports = [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
      ];

      # Not sure if this actually helps?
      boot.initrd.availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];

      fileSystems = {
        "/".options = [ "compress=zstd" ];
        "/home".options = [ "compress=zstd" ];
        "/nix".options = [ "compress=zstd" "noatime" ];
      };
      swapDevices = [ { device = "/swap"; } ];

      environment.systemPackages = with pkgs; [
        btrfs-progs
      ];

      time.timeZone = "UTC";
      i18n.defaultLocale = "en_US.UTF-8";
    })
    ({ pkgs, ... }: {
      networking.networkmanager.enable = true;

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
        home.stateVersion = "22.05";

        home.packages = with pkgs; [
          cozette
          fira-code
          eww-wayland
          keepassxc
          librewolf-wayland
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
