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
  crs = import ./commands/crs.nix {
    self = self;
    pkgs = pkgs;
  };
  extract = import ./commands/extract.nix {
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
  lofi = import ./wm-controls/lofi.nix {
    self = self;
    pkgs = pkgs;
  };
  music = import ./wm-controls/music.nix {
    self = self;
    pkgs = pkgs;
  };
  shutdown-script = import ./wm-controls/shutdown-script.nix {
    self = self;
    pkgs = pkgs;
  };
  switchmon = import ./wm-controls/switchmon.nix {
    self = self;
    pkgs = pkgs;
  };
  toggle_blur = import ./wm-controls/toggle_blur.nix {
    self = self;
    pkgs = pkgs;
  };
  toggle_float = import ./wm-controls/toggle_float.nix {
    self = self;
    pkgs = pkgs;
  };
  toggle_oppacity = import ./wm-controls/toggle_oppacity.nix {
    self = self;
    pkgs = pkgs;
  };
  toggle_waybar = import ./wm-controls/toggle_waybar.nix {
    self = self;
    pkgs = pkgs;
  };
  rebuild = import ./nix/rebuild.nix {
    host = host;
    self = self;
    pkgs = pkgs;
  };
  toolbelt = import ./commands/toolbelt.nix { pkgs = pkgs; };
  viconf = import ./commands/viconf.nix {
    pkgs = pkgs;
  };
	chscheme = import ./nix/chscheme.nix {
		pkgs = pkgs;
	};
in {
  home.packages = [
    compress
		chscheme
    keyring
    crs
    extract
    garbage-collect
    hyprland
    invoke
    lofi
    mcd
    music
    rebuild
    nsp
    runbg
    scheck
    shutdown-script
    splash
    switchmon
    toggle_blur
    toggle_float
    toggle_oppacity
    toggle_waybar
    toolbelt
    viconf
  ];
}
