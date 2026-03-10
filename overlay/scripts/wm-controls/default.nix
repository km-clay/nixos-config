{ super }:

{
  chpaper = super.callPackage ./chpaper.nix { };
  chscheme = super.callPackage ./chscheme.nix { };
  keyring = super.callPackage ./keyring.nix { };
  playshellsound = super.callPackage ./playshellsound.nix { };
  mkscreenshots = super.callPackage ./mkscreenshots.nix { };
  moveonscreen = super.callPackage ./moveonscreen.nix { };
  s_check = super.callPackage ./s_check.nix { };
  switchmon = super.callPackage ./switchmon.nix { };
}
