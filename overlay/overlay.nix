self: super: {
  myPkgs = {
    # Packages that I've made
    tinyfetch = super.callPackage ./tinyfetch/package.nix {};
    breezex-cursor = super.callPackage ./breezex-cursor/package.nix {};
    check_updates = super.callPackage ./check_updates/package.nix {};
  };
}
