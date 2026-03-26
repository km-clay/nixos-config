{ config, lib, ... }:
let
  cfg = config.movOpts.homeConfig;
  enabled = builtins.elem "graphical" cfg.enableProfiles
    || (cfg.profiles.graphical.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.programConfigs = {
      kittyConfig.enable  = true;
      fuzzelConfig.enable = true;
    };

    movOpts.envConfig = {
      hyprlandConfig.enable   = true;
      waybarConfig.enable     = true;
      userPkgs.enable         = true;
      stylixHomeConfig.enable = true;
      gtkConfig.enable        = true;
      swayncConfig.enable     = true;
      userServicesGraphical.enable = true;
      paperdConfig.enable     = true;
    };

    movOpts.homeFiles.enable = true;
  };
}
