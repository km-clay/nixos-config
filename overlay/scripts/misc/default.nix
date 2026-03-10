{ super }:

{
  color-commit = super.callPackage ./color-commit.nix { };
  mntstack = super.callPackage ./mntstack.nix { };
}
