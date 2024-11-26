{ host, pkgs, self, inputs, lib, username, config, ... }: {

  home.username = "${username}";
  home.homeDirectory =
    "/home/${username}";
  home.stateVersion =
    "24.05";

  programs.home-manager.enable = true;

  movOpts = {
    homeFiles.enable = true;

    # modules/home/environment
    envConfig = {
      starshipConfig.enable = true;
      userPkgs.enable = true;
      zshConfig = {
        shellAliases.enable = true;
        envVariables.enable = true;
        shellOptions.enable = true;
        extraConfig.enable = true;
      };
    };

    # modules/home/programs
    programConfigs = {
      autojumpConfig.enable = true;
      btopConfig.enable = true;
      ezaConfig.enable = true;
      fzfConfig.enable = true;
      gitConfig.enable = true;
      yaziConfig.enable = true;
      batConfig.enable = true;
    };
  };
}
