{ config, lib, ... }:
let
  cfg = config.movOpts.homeConfig;
  enabled = builtins.elem "cli" cfg.enableProfiles
    || (cfg.profiles.cli.enable or false);
in
{
  config = lib.mkIf enabled {
    movOpts.programConfigs = {
      autojumpConfig.enable = true;
      batConfig.enable      = true;
      btopConfig.enable     = true;
      ezaConfig.enable      = true;
      fzfConfig.enable      = true;
      gitConfig.enable      = true;
      yaziConfig.enable     = true;
      passConfig.enable     = true;
    };

    movOpts.envConfig = {
      starshipConfig.enable  = true;
      userServicesCli.enable = true;
      zshConfig = {
        shellAliases.enable = true;
        envVariables.enable = true;
        shellOptions.enable = true;
        extraConfig.enable  = true;
      };
      shedConfig = {
        shellAliases.enable = true;
        shellFunctions.enable  = true;
        shellOptions.enable = true;
        envVariables.enable = true;
        keyMaps.enable  = true;
        autoCmds.enable  = true;
        extraCompletion.enable  = true;
        extraConfig.enable  = true;
      };
    };
  };
}
