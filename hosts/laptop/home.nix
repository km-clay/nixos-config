{ host, pkgs, self, inputs, username, lib, config, ... }: {
  home.username = "${username}"; # Replace with your actual username
  home.homeDirectory =
    "/home/${username}"; # Replace with your actual home directory
  home.stateVersion =
    "24.05"; # Adjust this based on your system's NixOS version

  programs.home-manager.enable = true;

  movOpts = {
    # modules/home/files
    homeFiles.enable = true;

    # modules/home/environment
    envConfig = {
      hyprlandConfig = {
        enable = true;
        workspaceLayout = "singlemonitor";
        monitorNames = [ "eDP-1" ];
      };
      userPkgs.enable = true;
      stylixHomeConfig.enable = true;
      waybarConfig.enable = true;
      gtkConfig.enable = true;
      spicetifyConfig.enable = true;
      starshipConfig.enable = true;
      swayncConfig.enable = true;
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
