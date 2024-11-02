{lib, config, username, ...}: {
  options = {
    gitConfig.enable = lib.mkEnableOption "enables my git configuration";
  };
  config = lib.mkIf config.gitConfig.enable {
    programs.git = {
      enable = true;
      userEmail = "${username}@gmail.com";
      userName = "${username}";
    };
  };
}
