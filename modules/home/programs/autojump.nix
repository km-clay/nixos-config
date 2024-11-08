{lib, config, ...}: {
  options = {
    movOpts.programConfigs.autojumpConfig.enable = lib.mkEnableOption "enables my autojump options";
  };
  config = lib.mkIf config.movOpts.programConfigs.autojumpConfig.enable {
    programs.autojump = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
