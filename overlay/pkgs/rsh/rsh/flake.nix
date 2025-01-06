{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crate2nix.url = "github:nix-community/crate2nix";
  };
  outputs = { self, crate2nix, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          cargoNix = crate2nix.tools.${system}.appliedCargoNix {
            name = "rsh";
            src = ./.;
          };
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        with pkgs;
        rec {
          checks = {
            rustnix = cargoNix.rootCrate.build.override {
              runTests = true;
            };
          };
          packages = {
            rustnix = cargoNix.rootCrate.build;
            default = packages.rustnix;
            inherit rust-toolchain;
          };
          devShells.default = mkShell {
            buildInputs = [
              rust-bin.nightly.latest.default
              clang
              llvm
              libclang
              pam
            ];
            shellHook = ''
              exec zsh
            '';
          };
        }
      );
}
