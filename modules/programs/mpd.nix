{ pkgs, lib, config, userModule, ... }:
let
  extraOutputs = config.environment.extraOutputsToInstall;
  users = config.users.users;
in {
  imports = [
    (userModule ({ name, config, ... }:
    with lib;
    let
      cfg = config.programs.mpd;
      mpdConf = pkgs.writeText "mpd.conf" ''
        # This file was automatically generated by NixOS. Edit mpd's configuration
        # via NixOS' configuration.nix, as this file will be rewritten upon mpd's
        # restart.
        music_directory     "${cfg.musicDirectory}"
        playlist_directory  "${cfg.playlistDirectory}"
        ${optionalString (cfg.dbFile != null) ''
          db_file             "${cfg.dbFile}"
        ''}
        state_file          "${cfg.dataDir}/state"
        sticker_file        "${cfg.dataDir}/sticker.sql"
        ${optionalString (cfg.network.listenAddress != "any") ''bind_to_address "${cfg.network.listenAddress}"''}
        ${optionalString (cfg.network.port != 6600)  ''port "${toString cfg.network.port}"''}
        ${cfg.extraConfig}
      '';
      mpd = pkgs.symlinkJoin {
        name = "mpd";
        # There's gotta be a better way to inherit outputs
        paths = [ pkgs.mpd ] ++ builtins.map (name: pkgs.mpd.${name}) (intersectLists pkgs.mpd.outputs extraOutputs);
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/mpd \
            --add-flags "${mpdConf}"
        '';
      };
    in {
      options.programs.mpd = {
        enable = mkEnableOption "mpd";
        musicDirectory = mkOption {
          type = with types; either path (strMatching "(http|https|nfs|smb)://.+");
          default = "${cfg.dataDir}/music";
          defaultText = literalExpression ''"''${dataDir}/music"'';
          description = lib.mdDoc ''
            The directory or NFS/SMB network share where MPD reads music from. If left
            as the default value this directory will automatically be created before
            the MPD server starts, otherwise the sysadmin is responsible for ensuring
            the directory exists with appropriate ownership and permissions.
          '';
        };
        playlistDirectory = mkOption {
          type = types.path;
          default = "${cfg.dataDir}/playlists";
          defaultText = literalExpression ''"''${dataDir}/playlists"'';
          description = lib.mdDoc ''
            The directory where MPD stores playlists. If left as the default value
            this directory will automatically be created before the MPD server starts,
            otherwise the sysadmin is responsible for ensuring the directory exists
            with appropriate ownership and permissions.
          '';
        };
        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = lib.mdDoc ''
            Extra directives added to to the end of MPD's configuration file,
            mpd.conf. Basic configuration like file location and uid/gid
            is added automatically to the beginning of the file. For available
            options see `man 5 mpd.conf`'.
          '';
        };
        dataDir = mkOption {
          type = types.path;
          default = "${users.${name}.home}/.config/mpd";
          description = lib.mdDoc ''
            The directory where MPD stores its state, tag cache, playlists etc. If
            left as the default value this directory will automatically be created
            before the MPD server starts, otherwise the sysadmin is responsible for
            ensuring the directory exists with appropriate ownership and permissions.
          '';
        };

        network = {
          listenAddress = mkOption {
            type = types.str;
            default = "127.0.0.1";
            example = "any";
            description = lib.mdDoc ''
              The address for the daemon to listen on.
              Use `any` to listen on all addresses.
            '';
          };
          port = mkOption {
            type = types.int;
            default = 6600;
            description = lib.mdDoc ''
              This setting is the TCP port that is desired for the daemon to get assigned
              to.
            '';
          };
        };
        dbFile = mkOption {
          type = types.nullOr types.str;
          default = "${cfg.dataDir}/tag_cache";
          defaultText = literalExpression ''"''${dataDir}/tag_cache"'';
          description = lib.mdDoc ''
            The path to MPD's database. If set to `null` the
            parameter is omitted from the configuration.
          '';
        };
      };
      config = mkIf cfg.enable {
        packages = [ mpd ];
      };
    }))
  ];
}
