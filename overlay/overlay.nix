self: super: {
  myPkgs = {
    tinyfetch = super.callPackage ./tinyfetch/package.nix {};
    check_updates = super.callPackage ./check_updates/package.nix {};
  };
}
