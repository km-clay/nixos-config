{ super, root, writeShedBin }:

{
  chpaper = super.callPackage ./chpaper.nix { };
  chscheme = super.callPackage ./chscheme.nix { };
  keyring = super.callPackage ./keyring.nix { };
  playshellsound = super.callPackage ./playshellsound.nix { self = root; };
  mkscreenshots = super.callPackage ./mkscreenshots.nix { };
  moveonscreen = super.callPackage ./moveonscreen.nix { };
  s_check = super.callPackage ./s_check.nix { };
  switchmon = super.callPackage ./switchmon.nix { };
  ptt = super.callPackage ./ptt.nix { inherit writeShedBin; };
  ptt-status = super.callPackage ./ptt-status.nix { inherit writeShedBin; };
  gh-notify = super.callPackage ./gh-notify.nix { inherit writeShedBin; };
}
