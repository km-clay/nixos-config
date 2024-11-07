{lib, config, ...}: {
  options = {
    movOpts.fzfConfig.enable = lib.mkEnableOption "enables my fzf options";
  };
  config = lib.mkIf config.movOpts.fzfConfig.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
