{lib, config, ...}: {
  options = {
    autojumpOpts.enable = lib.mkEnableOption "enables my autojump options";
  };
  config = lib.mkIf config.autojumpOpts.enable {
    programs.autojump = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
