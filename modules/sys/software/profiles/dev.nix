{ config, lib, ... }:
let
  cfg = config.movOpts.softwareCfg;
  enabled = builtins.elem "dev" cfg.enableProfiles
    || (cfg.profiles.dev.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.softwareCfg.devPackages.enable = true;
  };
}
