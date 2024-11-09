{ host, lib, config, self, pkgs, ... }:
let
  fetchfromgh = import ./nix/fetchfromgh.nix { inherit pkgs; };
  vipkg = import ./commands/vipkg.nix { inherit pkgs; };
  keyring = import ./wm-controls/keyring.nix { inherit pkgs; };
  invoke = import ./commands/invoke.nix { inherit pkgs; };
  splash = import ./commands/splash.nix { inherit pkgs; };
  runbg = import ./commands/runbg.nix { inherit pkgs; };
  icanhazip = import ./commands/icanhazip.nix { inherit pkgs; };
  garbage-collect = import ./nix/garbage-collect.nix { inherit pkgs; };
  nsp = import ./nix/nsp.nix { inherit pkgs; };
  scheck = import ./wm-controls/s_check.nix { inherit pkgs; };
  switchmon = import ./wm-controls/switchmon.nix { inherit pkgs; };
  rebuild = import ./nix/rebuild.nix { inherit host self pkgs; };
  moveonscreen = import ./wm-controls/moveonscreen.nix { inherit pkgs; };
  toolbelt = import ./commands/toolbelt.nix { inherit pkgs; };
  viconf = import ./commands/viconf.nix { inherit pkgs; };
  chscheme = import ./wm-controls/chscheme.nix { inherit pkgs; };
  chpaper = import ./wm-controls/chpaper.nix { inherit pkgs; };
  mkscreenshots = import ./wm-controls/mkscreenshots.nix { inherit pkgs; };
  scriptOverride = doc: group: name:
    lib.mkEnableOption "${doc}" // {
      default = config.movOpts.movScripts.enable
        && config.movOpts.movScripts.${group}.enable;
    };
in {
  options = {
    movOpts.movScripts.enable =
      lib.mkEnableOption "Enables all pagedmov's scripts";

    # Enable or disable by group
    movOpts.movScripts.commandScripts.enable =
      lib.mkEnableOption "Enables all command scripts";
    movOpts.movScripts.hyprlandControls.enable =
      lib.mkEnableOption "Enables all Hyprland control scripts";
    movOpts.movScripts.nixShortcuts.enable =
      lib.mkEnableOption "Enables all Nix shortcut scripts";

    # Command Scripts
    movOpts.movScripts.commandScripts.vipkg.enable = scriptOverride
      "Search through the nixpkgs/pkgs directory for a package derivation. Useful for overrides."
      "commandScripts" "vipkg";
    movOpts.movScripts.commandScripts.icanhazip.enable =
      scriptOverride "Enables the icanhazip command" "commandScripts"
      "icanhazip";
    movOpts.movScripts.commandScripts.invoke.enable =
      scriptOverride "Enables the invoke command" "commandScripts" "invoke";
    movOpts.movScripts.commandScripts.runbg.enable =
      scriptOverride "Enables the runbg command - written by FrostPhoenix"
      "commandScripts" "runbg";
    movOpts.movScripts.commandScripts.splash.enable =
      scriptOverride "Enables the splash screen when opening a terminal"
      "commandScripts" "splash";
    movOpts.movScripts.commandScripts.toolbelt.enable =
      scriptOverride "Enables the toolbelt command" "commandScripts" "toolbelt";
    movOpts.movScripts.commandScripts.viconf.enable =
      scriptOverride "Enables the viconf command" "commandScripts" "viconf";

    # Hyprland Controls
    movOpts.movScripts.hyprlandControls.chpaper.enable =
      scriptOverride "Enables the chpaper command" "hyprlandControls" "chpaper";
    movOpts.movScripts.hyprlandControls.scheck.enable =
      scriptOverride "Enables the scheck command" "hyprlandControls" "scheck";
    movOpts.movScripts.hyprlandControls.chscheme.enable =
      scriptOverride "Enables the chscheme command" "hyprlandControls"
      "chscheme";
    movOpts.movScripts.hyprlandControls.keyring.enable =
      scriptOverride "Enables the keyring command" "hyprlandControls" "keyring";
    movOpts.movScripts.hyprlandControls.moveonscreen.enable =
      scriptOverride "Ensures floating windows remain on screen"
      "hyprlandControls" "moveonscreen";
    movOpts.movScripts.hyprlandControls.switchmon.enable =
      scriptOverride "Moves cursor to the center of the second monitor"
      "hyprlandControls" "switchmon";
    movOpts.movScripts.hyprlandControls.mkscreenshots.enable = scriptOverride
      "Generates screenshots, and updates the README.md with the current rev hash"
      "hyprlandControls" "switchmon";

    # Nix Shortcuts
    movOpts.movScripts.nixShortcuts.fetchfromgh.enable = scriptOverride
      "Provides a full pkgs.fetchFromGitHub call from a repository url"
      "nixShortcuts" "fetchfromgh";
    movOpts.movScripts.nixShortcuts.garbage-collect.enable =
      scriptOverride "Enables the garbage-collect script" "nixShortcuts"
      "garbage-collect";
    movOpts.movScripts.nixShortcuts.nsp.enable =
      scriptOverride "Enables nsp as an alias for 'nix-shell -p'" "nixShortcuts"
      "nsp";
    movOpts.movScripts.nixShortcuts.rebuild.enable = scriptOverride
      "Enables rebuild as an alias for 'sudo nixos-rebuild switch'"
      "nixShortcuts" "rebuild";
  };

  config = lib.mkIf config.movOpts.movScripts.enable {
    home.packages =
      lib.optionals config.movOpts.movScripts.commandScripts.invoke.enable [
        invoke
      ]
      # Command Scripts Overrides
      ++ lib.optionals config.movOpts.movScripts.commandScripts.vipkg.enable
      [ vipkg ]
      ++ lib.optionals config.movOpts.movScripts.commandScripts.runbg.enable
      [ runbg ]
      ++ lib.optionals config.movOpts.movScripts.commandScripts.icanhazip.enable
      [ icanhazip ]
      ++ lib.optionals config.movOpts.movScripts.commandScripts.splash.enable
      [ splash ]
      ++ lib.optionals config.movOpts.movScripts.commandScripts.toolbelt.enable
      [ toolbelt ]
      ++ lib.optionals config.movOpts.movScripts.commandScripts.viconf.enable [
        viconf
      ]

      # Hyprland Controls Overrides
      ++ lib.optionals config.movOpts.movScripts.hyprlandControls.chpaper.enable
      [ chpaper ]
      ++ lib.optionals config.movOpts.movScripts.hyprlandControls.scheck.enable
      [ scheck ] ++ lib.optionals
      config.movOpts.movScripts.hyprlandControls.chscheme.enable [ chscheme ]
      ++ lib.optionals config.movOpts.movScripts.hyprlandControls.keyring.enable
      [ keyring ] ++ lib.optionals
      config.movOpts.movScripts.hyprlandControls.moveonscreen.enable
      [ moveonscreen ] ++ lib.optionals
      config.movOpts.movScripts.hyprlandControls.switchmon.enable [ switchmon ]
      ++ lib.optionals
      config.movOpts.movScripts.hyprlandControls.mkscreenshots.enable [
        mkscreenshots
      ]

      # Nix Shortcuts Overrides
      ++ lib.optionals config.movOpts.movScripts.nixShortcuts.fetchfromgh.enable
      [ fetchfromgh ] ++ lib.optionals
      config.movOpts.movScripts.nixShortcuts.garbage-collect.enable
      [ garbage-collect ]
      ++ lib.optionals config.movOpts.movScripts.nixShortcuts.nsp.enable [ nsp ]
      ++ lib.optionals config.movOpts.movScripts.nixShortcuts.rebuild.enable
      [ rebuild ];
  };
}
