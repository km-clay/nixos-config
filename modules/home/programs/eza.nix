{lib, config, ...}: {
  options = {
    ezaConfig.enable = lib.mkEnableOption "enables my eza options";
  };
  config = lib.mkIf config.ezaConfig.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = false;
      extraOptions = ["-1" "-h" "--group-directories-first"];
      icons = "auto";
      git = true;
    };
  };
}
