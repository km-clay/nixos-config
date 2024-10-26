{
  host,
  self,
  pkgs,
  ...
}: let
  compress = import ./commands/compress.nix {
    self = self;
    pkgs = pkgs;
  };
  keyring = import ./wm-controls/keyring.nix {
    self = self;
    pkgs = pkgs;
  };
  invoke = import ./commands/invoke.nix {
    self = self;
    pkgs = pkgs;
  };
  splash = import ./commands/splash.nix {
    self = self;
    pkgs = pkgs;
  };
  scheck = import ./commands/s_check.nix {
    self = self;
    pkgs = pkgs;
  };
  runbg = import ./commands/runbg.nix {
    self = self;
    pkgs = pkgs;
  };
  mcd = import ./commands/mcd.nix {
    self = self;
    pkgs = pkgs;
  };
  garbage-collect = import ./nix/garbage-collect.nix {
    self = self;
    pkgs = pkgs;
  };
  nsp = import ./nix/nsp.nix {
    self = self;
    pkgs = pkgs;
  };
  hyprland = import ./wm-controls/hyprland.nix {pkgs = pkgs;};
  switchmon = import ./wm-controls/switchmon.nix {
    self = self;
    pkgs = pkgs;
  };
  rebuild = import ./nix/rebuild.nix {
    host = host;
    self = self;
    pkgs = pkgs;
  };
  moveonscreen = import ./wm-controls/moveonscreen.nix { pkgs = pkgs; };
  toolbelt = import ./commands/toolbelt.nix { pkgs = pkgs; };
  viconf = import ./commands/viconf.nix {
    pkgs = pkgs;
  };
	chscheme = import ./wm-controls/chscheme.nix {
		pkgs = pkgs;
	};
  chpaper = import ./wm-controls/chpaper.nix { pkgs = pkgs; };
in {
  home.packages = [
    compress
    chpaper
		chscheme
    keyring
    garbage-collect
    hyprland
    invoke
    mcd
    rebuild
    nsp
    runbg
    scheck
    splash
    switchmon
    moveonscreen
    toolbelt
    viconf
  ];
}
