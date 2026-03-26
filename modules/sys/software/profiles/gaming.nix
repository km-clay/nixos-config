{ config, lib, ... }:
let
  cfg = config.movOpts.softwareCfg;
  enabled = builtins.elem "gaming" cfg.enableProfiles
    || (cfg.profiles.gaming.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.softwareCfg.gamingPackages.enable = true;
  };
}
