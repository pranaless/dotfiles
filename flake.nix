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
    mkHosts = with nixpkgs.lib; let
      extendLib = l: l.extend (_: _: { dl = lib; });
    in builtins.mapAttrs (hostName: {
      system,
      # flakes ? {},
      modules ? []
    }: let
      # flakesPkgs = builtins.mapAttrs (_: flake: flake.packages.${system}) flakes;
    in nixosSystem {
      inherit system;
      lib = extendLib nixpkgs.lib;
      modules = [
        home-manager.nixosModules.default
        ./modules
        {
          config = {
            nixpkgs.overlays = [
              (self: super: {
                lib = extendLib super.lib;
              })
              (import ./pkgs)
              # (self: super: flakesPkgs)
            ];
            nix.settings = {
              trusted-users = [ "@wheel" ];
              experimental-features = [ "nix-command" "flakes" ];
              sandbox = true;
            };
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
            };
            system.configurationRevision = mkIf (self ? rev) self.rev;
          };
        }
        ({ pkgs, ... }: {
          config = {
            boot.loader.systemd-boot.enable = mkDefault true;
            boot.loader.efi.canTouchEfiVariables = mkDefault true;

            networking.hostName = hostName;

            environment.systemPackages = with pkgs; [
              bc
              fd
              git
              ripgrep
            ];
          };
        })
      ] ++ modules;
    });
  in {
    inherit lib;
  
    nixosConfigurations = mkHosts {
      humus = import ./hosts/humus inputs;
    };
  };
}
