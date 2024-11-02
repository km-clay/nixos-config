{lib, config, ...}: {
  options = {
    fzfConfig.enable = lib.mkEnableOption "enables my fzf options";
  };
  config = lib.mkIf config.fzfConfig.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
