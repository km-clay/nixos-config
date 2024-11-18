{ username, ... }:

{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  movOpts = {
    homeFiles.enable = true;
    envConfig = {
      hyprlandConfig = {
        enable = true;
        monitorNames = [ "eDP-1" ];
        workspaceLayout = "singlemonitor";
      };
      userPkgs.enable = true;
      stylixHomeConfig.enable = true;
      gtkConfig.enable = true;
      starshipConfig.enable = true;
      swayncConfig.enable = true;
      zshConfig = {
        shellAliases.enable = true;
        envVariables.enable = true;
        shellOptions.enable = true;
        extraConfig.enable = true;
      };
    };
    programConfigs = {
      autojumpConfig.enable = true;
      btopConfig.enable = true;
      ezaConfig.enable = true;
      firefoxConfig.enable = true;
      fuzzelConfig.enable = true;
      fzfConfig.enable = true;
      gitConfig.enable = true;
      kittyConfig.enable = true;
      yaziConfig.enable = true;
      passConfig.enable = true;
      batConfig.enable = true;
    };
  };
}
