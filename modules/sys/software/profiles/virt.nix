{ config, lib, ... }:
let
  cfg = config.movOpts.softwareCfg;
  enabled = builtins.elem "virt" cfg.enableProfiles
    || (cfg.profiles.virt.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.softwareCfg.virtPackages.enable = true;
  };
}
