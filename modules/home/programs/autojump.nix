{lib, config, ...}: {
  options = {
    movOpts.autojumpConfig.enable = lib.mkEnableOption "enables my autojump options";
  };
  config = lib.mkIf config.movOpts.autojumpConfig.enable {
    programs.autojump = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
