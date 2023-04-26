{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland }@inputs:
  let
    lib = import ./lib {
      inherit self home-manager;
      inherit (nixpkgs) lib;
    };
    baseModules = [
      home-manager.nixosModules.default
      ./modules
      ({ pkgs, lib, ... }: {
        config = {
          nixpkgs.overlays = [ (import ./pkgs) ];
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

          boot.loader.systemd-boot.enable = lib.mkDefault true;
          boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

          environment.systemPackages = with pkgs; [
            bc
            fd
            git
            ripgrep
          ];
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
        value = let
          extendLib = l: l.extend (_: _: { dl = lib; });
        in nixpkgs.lib.nixosSystem {
          inherit system;
          lib = extendLib nixpkgs.lib;
          modules = baseModules ++ [
            ({ lib, ... }: {
              nixpkgs.overlays = [ (_: super: { lib = extendLib super.lib; }) ];
              networking.hostName = hostName;
            })
          ] ++ modules;
        };
      }))
      builtins.listToAttrs
    ];
  in {
    inherit lib;
  
    nixosConfigurations = mkHosts [
      ./hosts/humus
    ];
  };
}
