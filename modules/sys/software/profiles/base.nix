{ config, lib, ... }:
let
  cfg = config.movOpts.softwareCfg;
  enabled = builtins.elem "base" cfg.enableProfiles
    || (cfg.profiles.base.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.softwareCfg.basePackages.enable = true;
  };
}
