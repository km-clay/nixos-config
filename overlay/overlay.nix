{ host, root, ... }: self: super:

let
  extraFigletFonts = super.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "master";
    sha256 = "sha256-dAs7N66D2Fpy4/UB5Za1r2qb1iSAJR6TMmau1asxgtY=";
  };
in
{
  toilet = super.toilet.overrideAttrs (old: {
    buildInputs = old.buildInputs or [ ] ++ [ extraFigletFonts ];

    installPhase = ''
      make install PREFIX=$out
      mkdir -p $out/share/figlet
      cp -r ${extraFigletFonts}/* $out/share/figlet
    '';
  });
  myPkgs = {
    # Packages that I've made
    tinyfetch = super.callPackage ./tinyfetch/package.nix {};
    breezex-cursor = super.callPackage ./breezex-cursor/package.nix {};
  };
  myScripts = {
    # Scripts written using pkgs.writeShellApplication
    icanhazip = super.callPackage ./scripts/commands/icanhazip.nix {};
    invoke = super.callPackage ./scripts/commands/invoke.nix { self = root; };
    git-compose = super.callPackage ./scripts/commands/git-compose.nix { self = root; };
    runbg = super.callPackage ./scripts/commands/runbg.nix {};
    splash = super.callPackage ./scripts/commands/splash.nix {};
    toolbelt = super.callPackage ./scripts/commands/toolbelt.nix {};
    viconf = super.callPackage ./scripts/commands/viconf.nix {};
    vipkg = super.callPackage ./scripts/commands/vipkg.nix {};
    fetchfromgh = super.callPackage ./scripts/nix/fetchfromgh.nix {};
    garbage-collect = super.callPackage ./scripts/nix/garbage-collect.nix {};
    check_updates = super.callPackage ./scripts/nix/check_updates.nix {};
    rebuild = super.callPackage ./scripts/nix/rebuild.nix { inherit host; self = root; };
    chpaper = super.callPackage ./scripts/wm-controls/chpaper.nix {};
    chscheme = super.callPackage ./scripts/wm-controls/chscheme.nix {};
    keyring = super.callPackage ./scripts/wm-controls/keyring.nix {};
    playshellsound = super.callPackage ./scripts/wm-controls/playshellsound.nix {};
    mkscreenshots = super.callPackage ./scripts/wm-controls/mkscreenshots.nix {};
    moveonscreen = super.callPackage ./scripts/wm-controls/moveonscreen.nix {};
    s_check = super.callPackage ./scripts/wm-controls/s_check.nix {};
    switchmon = super.callPackage ./scripts/wm-controls/switchmon.nix {};
    color-commit = super.callPackage ./scripts/misc/color-commit.nix {};
    mntstack = super.callPackage ./scripts/misc/mntstack.nix {};
  };
}
