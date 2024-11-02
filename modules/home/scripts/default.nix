{
  host,
  lib,
  config,
  self,
  pkgs,
  ...
}: let
  keyring         = import ./wm-controls/keyring.nix { inherit self pkgs; };
  invoke          = import ./commands/invoke.nix { inherit self pkgs; };
  splash          = import ./commands/splash.nix { inherit self pkgs; };
  runbg           = import ./commands/runbg.nix { inherit self pkgs; };
  garbage-collect = import ./nix/garbage-collect.nix { inherit self pkgs; };
  nsp             = import ./nix/nsp.nix { inherit self pkgs; };
  scheck          = import ./wm-controls/s_check.nix { inherit self pkgs; };
  switchmon       = import ./wm-controls/switchmon.nix { inherit self pkgs; };
  rebuild         = import ./nix/rebuild.nix { inherit host self pkgs; };
  moveonscreen    = import ./wm-controls/moveonscreen.nix { inherit pkgs; };
  toolbelt        = import ./commands/toolbelt.nix { inherit pkgs; };
  viconf          = import ./commands/viconf.nix { inherit pkgs; };
  chscheme        = import ./wm-controls/chscheme.nix { inherit pkgs; };
  chpaper         = import ./wm-controls/chpaper.nix { inherit pkgs; };
in {
  options = {
    pagedmovScripts.enable = lib.mkEnableOption "Enables all pagedmov's scripts";

    # Enable or disable by group
    pagedmovScripts.commandScripts.enable =
      lib.mkEnableOption "Enables all command scripts";
    pagedmovScripts.hyprlandControls.enable =
      lib.mkEnableOption "Enables all Hyprland control scripts";
    pagedmovScripts.nixShortcuts.enable =
      lib.mkEnableOption "Enables all Nix shortcut scripts";

    # These options override individual scripts
    pagedmovScripts.commandScripts.invoke.enable =
      lib.mkDefault (config.pagedmovScripts.commandScripts.enable) // lib.mkEnableOption "Enables the invoke command";
    pagedmovScripts.commandScripts.runbg.enable =
      lib.mkDefault (config.pagedmovScripts.commandScripts.enable) // lib.mkEnableOption "Enables the runbg command - written by FrostPhoenix";
    pagedmovScripts.commandScripts.splash.enable =
      lib.mkDefault (config.pagedmovScripts.commandScripts.enable) // lib.mkEnableOption "Enables the splash screen when opening a terminal";
    pagedmovScripts.commandScripts.toolbelt.enable =
      lib.mkDefault (config.pagedmovScripts.commandScripts.enable) // lib.mkEnableOption "Enables the toolbelt command";
    pagedmovScripts.commandScripts.viconf.enable =
      lib.mkDefault (config.pagedmovScripts.commandScripts.enable) // lib.mkEnableOption "Enables the viconf command";

    pagedmovScripts.hyprlandControls.chpaper.enable =
      lib.mkDefault (config.pagedmovScripts.hyprlandControls.enable) // lib.mkEnableOption "Enables the chpaper command";
    pagedmovScripts.hyprlandControls.scheck.enable =
      lib.mkDefault (config.pagedmovScripts.hyprlandControls.enable) // lib.mkEnableOption "Enables the scheck command";
    pagedmovScripts.hyprlandControls.chscheme.enable =
      lib.mkDefault (config.pagedmovScripts.hyprlandControls.enable) // lib.mkEnableOption "Enables the chscheme command";
    pagedmovScripts.hyprlandControls.keyring.enable =
      lib.mkDefault (config.pagedmovScripts.hyprlandControls.enable) // lib.mkEnableOption "Enables the keyring command";
    pagedmovScripts.hyprlandControls.moveonscreen.enable =
      lib.mkDefault (config.pagedmovScripts.hyprlandControls.enable) // lib.mkEnableOption "Ensures floating windows remain on screen";
    pagedmovScripts.hyprlandControls.switchmon.enable =
      lib.mkDefault (config.pagedmovScripts.hyprlandControls.enable) // lib.mkEnableOption "Moves cursor to the center of the second monitor";

    pagedmovScripts.nixShortcuts.garbage-collect.enable =
      lib.mkDefault (config.pagedmovScripts.nixShortcuts.enable) // lib.mkEnableOption "Enables the garbage-collect script";
    pagedmovScripts.nixShortcuts.nsp.enable =
      lib.mkDefault (config.pagedmovScripts.nixShortcuts.enable) // lib.mkEnableOption "Enables nsp as an alias for 'nix-shell -p'";
    pagedmovScripts.nixShortcuts.rebuild.enable =
      lib.mkDefault (config.pagedmovScripts.nixShortcuts.enable) // lib.mkEnableOption "Enables rebuild as an alias for 'sudo nixos-rebuild switch'";
  };

  config = lib.mkIf config.pagedmovScripts.enable {
    home.packages = lib.optionals config.pagedmovScripts.commandScripts.invoke.enable [ invoke ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.runbg.enable [ runbg ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.splash.enable [ splash ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.toolbelt.enable [ toolbelt ]
                    ++ lib.optionals config.pagedmovScripts.commandScripts.viconf.enable [ viconf ]

                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.chpaper.enable [ chpaper ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.scheck.enable [ scheck ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.chscheme.enable [ chscheme ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.keyring.enable [ keyring ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.moveonscreen.enable [ moveonscreen ]
                    ++ lib.optionals config.pagedmovScripts.hyprlandControls.switchmon.enable [ switchmon ]

                    ++ lib.optionals config.pagedmovScripts.nixShortcuts.garbage-collect.enable [ garbage-collect ]
                    ++ lib.optionals config.pagedmovScripts.nixShortcuts.nsp.enable [ nsp ]
                    ++ lib.optionals config.pagedmovScripts.nixShortcuts.rebuild.enable [ rebuild ];
  };
}
