{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, home-manager, ... }@inputs:
  let
    baseModules = [
      home-manager.nixosModules.default
      ({ pkgs, lib, ... }: {
        config = {
          nix.settings = {
            trusted-users = [ "@wheel" ];
            experimental-features = [ "nix-command" "flakes" ];
            sandbox = true;
          };
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
          };
          system.configurationRevision = lib.mkIf (self ? rev) self.rev;

          boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
          boot.loader.systemd-boot.enable = lib.mkDefault true;
          boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

          environment.systemPackages = with pkgs; [
            bc
            fd
            git
            ripgrep
          ];
          environment.defaultPackages = [ ];
        };
      })
    ];
    mkHosts = with nixpkgs.lib; flip pipe [
      (builtins.map (v: import v inputs))
      (builtins.map ({
        hostName,
        system,
        modules ? [],
      }: {
        name = hostName;
        value = nixosSystem {
          inherit system;
          modules = baseModules ++ [
            {
              networking.hostName = hostName;
            }
          ] ++ modules;
        };
      }))
      builtins.listToAttrs
    ];
  in {
    nixosConfigurations = mkHosts [
      ./hosts/humus
    ];
  };
}
