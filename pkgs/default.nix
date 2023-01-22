self: super: {
  swww = super.swww or (super.callPackage ./swww.nix { });
}
