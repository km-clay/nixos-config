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
  scriptOverride =
    doc:
    group:
    name:
    lib.mkEnableOption
    "${doc}" // {
      default = config.movScripts.enable && config.movScripts.${group}.enable;
    };
in {
  options = {
    movScripts.enable = lib.mkEnableOption "Enables all pagedmov's scripts";

    # Enable or disable by group
    movScripts.commandScripts.enable =
      lib.mkEnableOption "Enables all command scripts";
    movScripts.hyprlandControls.enable =
      lib.mkEnableOption "Enables all Hyprland control scripts";
    movScripts.nixShortcuts.enable =
      lib.mkEnableOption "Enables all Nix shortcut scripts";

    # Individual options using scriptOverride or mkEnableOption directly
    movScripts.commandScripts.invoke.enable =
      scriptOverride "Enables the invoke command" "commandScripts" "invoke";
    movScripts.commandScripts.runbg.enable =
      scriptOverride "Enables the runbg command - written by FrostPhoenix" "commandScripts" "runbg";
    movScripts.commandScripts.splash.enable =
      scriptOverride "Enables the splash screen when opening a terminal" "commandScripts" "splash";
    movScripts.commandScripts.toolbelt.enable =
      scriptOverride "Enables the toolbelt command" "commandScripts" "toolbelt";
    movScripts.commandScripts.viconf.enable =
      scriptOverride "Enables the viconf command" "commandScripts" "viconf";

    movScripts.hyprlandControls.chpaper.enable =
      scriptOverride "Enables the chpaper command" "hyprlandControls" "chpaper";
    movScripts.hyprlandControls.scheck.enable =
      scriptOverride "Enables the scheck command" "hyprlandControls" "scheck";
    movScripts.hyprlandControls.chscheme.enable =
      scriptOverride "Enables the chscheme command" "hyprlandControls" "chscheme";
    movScripts.hyprlandControls.keyring.enable =
      scriptOverride "Enables the keyring command" "hyprlandControls" "keyring";
    movScripts.hyprlandControls.moveonscreen.enable =
      scriptOverride "Ensures floating windows remain on screen" "hyprlandControls" "moveonscreen";
    movScripts.hyprlandControls.switchmon.enable =
      scriptOverride "Moves cursor to the center of the second monitor" "hyprlandControls" "switchmon";

    movScripts.nixShortcuts.garbage-collect.enable =
      scriptOverride "Enables the garbage-collect script" "nixShortcuts" "garbage-collect";
    movScripts.nixShortcuts.nsp.enable =
      scriptOverride "Enables nsp as an alias for 'nix-shell -p'" "nixShortcuts" "nsp";
    movScripts.nixShortcuts.rebuild.enable =
      scriptOverride "Enables rebuild as an alias for 'sudo nixos-rebuild switch'" "nixShortcuts" "rebuild";
  };

  config = lib.mkIf config.movScripts.enable {
    home.packages = lib.optionals config.movScripts.commandScripts.invoke.enable [ invoke ]
                    ++ lib.optionals config.movScripts.commandScripts.runbg.enable [ runbg ]
                    ++ lib.optionals config.movScripts.commandScripts.splash.enable [ splash ]
                    ++ lib.optionals config.movScripts.commandScripts.toolbelt.enable [ toolbelt ]
                    ++ lib.optionals config.movScripts.commandScripts.viconf.enable [ viconf ]

                    ++ lib.optionals config.movScripts.hyprlandControls.chpaper.enable [ chpaper ]
                    ++ lib.optionals config.movScripts.hyprlandControls.scheck.enable [ scheck ]
                    ++ lib.optionals config.movScripts.hyprlandControls.chscheme.enable [ chscheme ]
                    ++ lib.optionals config.movScripts.hyprlandControls.keyring.enable [ keyring ]
                    ++ lib.optionals config.movScripts.hyprlandControls.moveonscreen.enable [ moveonscreen ]
                    ++ lib.optionals config.movScripts.hyprlandControls.switchmon.enable [ switchmon ]

                    ++ lib.optionals config.movScripts.nixShortcuts.garbage-collect.enable [ garbage-collect ]
                    ++ lib.optionals config.movScripts.nixShortcuts.nsp.enable [ nsp ]
                    ++ lib.optionals config.movScripts.nixShortcuts.rebuild.enable [ rebuild ];
  };
}
