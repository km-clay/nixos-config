{ super, root }:

{
  icanhazip = super.callPackage ./icanhazip.nix { };
  invoke = super.callPackage ./invoke.nix { self = root; };
  git-compose = super.callPackage ./git-compose.nix { self = root; };
  runbg = super.callPackage ./runbg.nix { };
  splash = super.callPackage ./splash.nix { };
  toolbelt = super.callPackage ./toolbelt.nix { };
  viconf = super.callPackage ./viconf.nix { };
  vipkg = super.callPackage ./vipkg.nix { };
}
