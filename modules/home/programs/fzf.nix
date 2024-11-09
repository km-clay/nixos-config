{ lib, config, ... }: {
  options = {
    movOpts.programConfigs.fzfConfig.enable =
      lib.mkEnableOption "enables my fzf options";
  };
  config = lib.mkIf config.movOpts.programConfigs.fzfConfig.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
