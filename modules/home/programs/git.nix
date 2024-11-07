{lib, config, username, ...}: {
  options = {
    movOpts.gitConfig.enable = lib.mkEnableOption "enables my git configuration";
  };
  config = lib.mkIf config.movOpts.gitConfig.enable {
    programs.git = {
      enable = true;
      userEmail = "${username}@gmail.com";
      userName = "${username}";
    };
  };
}
