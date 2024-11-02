{
  host,
  lib,
  config,
  self,
  pkgs,
  ...
}: let
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
  runbg = import ./commands/runbg.nix {
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
  scheck = import ./wm-controls/s_check.nix { self = self; pkgs = pkgs;};
  switchmon = import ./wm-controls/switchmon.nix {
    self = self;
    pkgs = pkgs;
  };
  rebuild = import ./nix/rebuild.nix {
    host = host;
    self = self;
    pkgs = pkgs;
  };
  moveonscreen = import ./wm-controls/moveonscreen.nix {pkgs = pkgs;};
  toolbelt = import ./commands/toolbelt.nix {pkgs = pkgs;};
  viconf = import ./commands/viconf.nix {
    pkgs = pkgs;
  };
  chscheme = import ./wm-controls/chscheme.nix {
    pkgs = pkgs;
  };
  chpaper = import ./wm-controls/chpaper.nix {pkgs = pkgs;};
in {
  options = {
    pagedmovScripts.enable = lib.mkEnableOption "enables pagedmov's scripts";

    pagedmovScripts.commandScripts.invoke.enable =
      lib.mkEnableOption "enables the invoke command";
    pagedmovScripts.commandScripts.runbg.enable =
      lib.mkEnableOption "enables the runbg command - written by FrostPhoenix";
    pagedmovScripts.commandScripts.splash.enable =
      lib.mkEnableOption "enables the splash screen when opening a terminal";
    pagedmovScripts.commandScripts.toolbelt.enable =
      lib.mkEnableOption "enables the toolbelt command";
    pagedmovScripts.commandScripts.viconf.enable =
      lib.mkEnableOption "enables the viconf command";

    pagedmovScripts.hyprlandControls.chpaper.enable =
      lib.mkEnableOption "enables the chpaper command";
    pagedmovScripts.hyprlandControls.scheck.enable =
      lib.mkEnableOption "enables the chpaper command";
    pagedmovScripts.hyprlandControls.chscheme.enable =
      lib.mkEnableOption "enables the chscheme command";
    pagedmovScripts.hyprlandControls.keyring.enable =
      lib.mkEnableOption "enables the keyring command";
    pagedmovScripts.hyprlandControls.moveonscreen.enable =
      lib.mkEnableOption "enables the moveonscreen command, makes sure that the edges of floating windows are always on screen";
    pagedmovScripts.hyprlandControls.switchmon.enable =
      lib.mkEnableOption "moves your cursor to the center of your second monitor; currently only supports two monitors";

    pagedmovScripts.nixShortcuts.garbage-collect.enable =
      lib.mkEnableOption "enables the garbage-collect script, runs nixos garbage collection and empties the gtrash bin";
    pagedmovScripts.nixShortcuts.nsp.enable =
      lib.mkEnableOption "enables nsp, essentially an alias for 'nix-shell -p'";
    pagedmovScripts.nixShortcuts.rebuild.enable =
      lib.mkEnableOption "enables rebuild, an alias for 'sudo nixos-rebuild switch --flake $FLAKEPATH#$(hostname)'";
  };
  config = lib.mkIf config.pagedmovScripts.enable {
    home.packages = lib.optionals config.pagedmovScripts.commandScripts.invoke.enable [ invoke ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.runbg.enable [ runbg ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.splash.enable [ splash ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.toolbelt.enable [ toolbelt ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.viconf.enable [ viconf ]

                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.chpaper.enable [ chpaper ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.chpaper.enable [ scheck ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.chscheme.enable [ chscheme ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.keyring.enable [ keyring ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.moveonscreen.enable [ moveonscreen ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.switchmon.enable [ switchmon ]

                    ++ lib.optionals config.pagedmovScripts.nixShortcuts.garbage-collect.enable [ garbage-collect ]
                    ++ lib.optionals config.pagedmovScripts.nixShortcuts.nsp.enable [ nsp ]
                    ++ lib.optionals config.pagedmovScripts.nixShortcuts.rebuild.enable [ rebuild ];
  };
}
