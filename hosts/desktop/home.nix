{ username, lib, config, ... }: {
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
      zshConfig.enable = true;
    };

    # modules/home/programs
    programConfigs = {
      autojumpConfig.enable = true;
      btopConfig.enable = true;
      cavaConfig.enable = true;
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

    # modules/home/scripts
    movScripts = {
      enable = true;
      commandScripts.enable = true;
      hyprlandControls.enable = true;
      nixShortcuts.enable = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
