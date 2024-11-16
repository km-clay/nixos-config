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
  scriptList = [
    fetchfromgh
    vipkg
    keyring
    invoke
    splash
    runbg
    icanhazip
    garbage-collect
    nsp
    scheck
    switchmon
    rebuild
    moveonscreen
    toolbelt
    viconf
    chscheme
    chpaper
    mkscreenshots
  ];
  loadScript = scriptName:
    lib.foldl' (acc: dir:
      if builtins.pathExists "${dir}/${scriptName}.nix"
      then acc // { inherit (import "${dir}/${scriptName}.nix" { inherit pkgs; }) scriptName; }
      else acc
    ) {} scriptList;
in {
  options = {
    movOpts.enabledScripts =
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
