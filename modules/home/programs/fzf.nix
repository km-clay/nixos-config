{lib, config, ...}: {
  options = {
    fzfOpts.enable = lib.mkEnableOption "enables my fzf options";
  };
  config = lib.mkIf config.fzfOpts.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
