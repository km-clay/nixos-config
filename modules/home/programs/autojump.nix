{lib, config, ...}: {
  options = {
    autojumpConfig.enable = lib.mkEnableOption "enables my autojump options";
  };
  config = lib.mkIf config.autojumpConfig.enable {
    programs.autojump = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
