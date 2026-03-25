{ lib, config, ... }:
{
  options = {
    movOpts.programConfigs.yaziConfig.enable = lib.mkEnableOption "enables my yazi config";
  };
  config = lib.mkIf config.movOpts.programConfigs.yaziConfig.enable {
    programs.yazi = {
      enable = true;
      theme = lib.mkForce {};
      enableZshIntegration = true;
      shellWrapperName = "y";
    };
  };
}
