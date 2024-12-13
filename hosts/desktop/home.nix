{ username, ... }: {
  home.username = "${username}";
  home.homeDirectory =
    "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  movOpts = {
    # modules/home/files
    homeFiles.enable = true;

    # modules/home/environment
    envConfig = {
      hyprlandConfig = {
        enable = true;
        monitorNames = [ "HDMI-A-1" "DP-1" ];
        workspaceLayout = "dualmonitor";
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
      cavaConfig.enable = false;
      ezaConfig.enable = true;
      fuzzelConfig.enable = true;
      fzfConfig.enable = true;
      gitConfig.enable = true;
      kittyConfig.enable = true;
      yaziConfig.enable = true;
      passConfig.enable = true;
      batConfig.enable = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
