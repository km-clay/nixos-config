{lib, config, ...}: {
  options = {
    yaziConfig.enable = lib.mkEnableOption "enables my yazi config";
  };
  config = lib.mkIf config.yaziConfig.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
