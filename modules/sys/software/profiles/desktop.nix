{ config, lib, ... }:
let
  cfg = config.movOpts.softwareCfg;
  enabled = builtins.elem "desktop" cfg.enableProfiles
    || (cfg.profiles.desktop.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.softwareCfg.desktopPackages.enable = true;
  };
}
