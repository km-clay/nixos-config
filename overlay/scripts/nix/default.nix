{ super, host, root }:

{
  fetchfromgh = super.callPackage ./templates/fetchfromgh.nix {};
  mkshell = super.callPackage ./templates/mkshell.nix {};
  garbage-collect = super.callPackage ./garbage-collect.nix {};
  check_updates = super.callPackage ./check_updates.nix {};
  rebuild = super.callPackage ./rebuild.nix { inherit host; self = root; };
}
