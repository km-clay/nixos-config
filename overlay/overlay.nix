{ host, root, ... }: self: super:
{
  myPkgs = {
    # Packages that I've made
    tinyfetch = super.callPackage ./tinyfetch/package.nix {};
    breezex-cursor = super.callPackage ./breezex-cursor/package.nix {};
  };
  myScripts = {
    # Scripts written using pkgs.writeShellApplication
    icanhazip = super.callPackage ./scripts/commands/icanhazip.nix {};
    invoke = super.callPackage ./scripts/commands/invoke.nix { self = root; };
    git-compose = super.callPackage ./scripts/commands/git-compose.nix {};
    runbg = super.callPackage ./scripts/commands/runbg.nix {};
    splash = super.callPackage ./scripts/commands/splash.nix {};
    toolbelt = super.callPackage ./scripts/commands/toolbelt.nix {};
    viconf = super.callPackage ./scripts/commands/viconf.nix {};
    vipkg = super.callPackage ./scripts/commands/vipkg.nix {};
    fetchfromgh = super.callPackage ./scripts/nix/fetchfromgh.nix {};
    garbage-collect = super.callPackage ./scripts/nix/garbage-collect.nix {};
    check_updates = super.callPackage ./scripts/nix/check_updates.nix {};
    nsp = super.callPackage ./scripts/nix/nsp.nix {};
    rebuild = super.callPackage ./scripts/nix/rebuild.nix { inherit host; self = root; };
    chpaper = super.callPackage ./scripts/wm-controls/chpaper.nix {};
    chscheme = super.callPackage ./scripts/wm-controls/chscheme.nix {};
    keyring = super.callPackage ./scripts/wm-controls/keyring.nix {};
    mkscreenshots = super.callPackage ./scripts/wm-controls/mkscreenshots.nix {};
    moveonscreen = super.callPackage ./scripts/wm-controls/moveonscreen.nix {};
    s_check = super.callPackage ./scripts/wm-controls/s_check.nix {};
    switchmon = super.callPackage ./scripts/wm-controls/switchmon.nix {};
  };
}
