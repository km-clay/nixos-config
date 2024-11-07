{lib, config, ...}: {
  options = {
    movOpts.yaziConfig.enable = lib.mkEnableOption "enables my yazi config";
  };
  config = lib.mkIf config.movOpts.yaziConfig.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
