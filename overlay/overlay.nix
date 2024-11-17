{ host, root, ... }: self: super:
{
  myPkgs = {
    # Packages that I've made
    tinyfetch = super.callPackage ./tinyfetch/package.nix {};
    breezex-cursor = super.callPackage ./breezex-cursor/package.nix {};
    check_updates = super.callPackage ./check_updates/package.nix {};
  };
  myScripts = {
    # Scripts written using pkgs.writeShellApplication
    icanhazip = super.callPackage ./scripts/commands/icanhazip.nix { pkgs = super; };
    invoke = super.callPackage ./scripts/commands/invoke.nix { pkgs = super; self = root; };
    git-compose = super.callPackage ./scripts/commands/git-compose.nix { pkgs = super; };
    runbg = super.callPackage ./scripts/commands/runbg.nix { pkgs = super; };
    splash = super.callPackage ./scripts/commands/splash.nix { pkgs = super; };
    toolbelt = super.callPackage ./scripts/commands/toolbelt.nix { pkgs = super; };
    viconf = super.callPackage ./scripts/commands/viconf.nix { pkgs = super; };
    vipkg = super.callPackage ./scripts/commands/vipkg.nix { pkgs = super; };
    fetchfromgh = super.callPackage ./scripts/nix/fetchfromgh.nix { pkgs = super; };
    garbage-collect = super.callPackage ./scripts/nix/garbage-collect.nix { pkgs = super; };
    nsp = super.callPackage ./scripts/nix/nsp.nix { pkgs = super; };
    rebuild = super.callPackage ./scripts/nix/rebuild.nix { inherit host; self = root; pkgs = super; };
    chpaper = super.callPackage ./scripts/wm-controls/chpaper.nix { pkgs = super; };
    chscheme = super.callPackage ./scripts/wm-controls/chscheme.nix { pkgs = super; };
    keyring = super.callPackage ./scripts/wm-controls/keyring.nix { pkgs = super; };
    mkscreenshots = super.callPackage ./scripts/wm-controls/mkscreenshots.nix { pkgs = super; };
    moveonscreen = super.callPackage ./scripts/wm-controls/moveonscreen.nix { pkgs = super; };
    s_check = super.callPackage ./scripts/wm-controls/s_check.nix { pkgs = super; };
    switchmon = super.callPackage ./scripts/wm-controls/switchmon.nix { pkgs = super; };
  };
}
