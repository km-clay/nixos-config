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
    hyprlandConfig = {
      enable = true;
      workspaceLayout = "singlemonitor";
      monitorNames = [ "eDP-1" ];
    };
    autojumpConfig.enable = true;
    stylixHomeConfig.enable = true;
    waybarConfig.enable = true;
    gtkConfig.enable = true;
    spicetifyConfig.enable = true;
    starshipConfig.enable = true;

    # modules/home/programs
    btopConfig.enable = true;
    swayncConfig.enable = true;
    userPkgs.enable = true;
    cavaConfig.enable = true;
    ezaConfig.enable = true;
    firefoxConfig.enable = true;
    fuzzelConfig.enable = true;
    fzfConfig.enable = true;
    gitConfig.enable = true;
    kittyConfig.enable = true;
    yaziConfig.enable = true;
    zshConfig.enable = true;
    passConfig.enable = true;
    batConfig.enable = true;

    # modules/home/scripts
    movScripts = {
      enable = true;
      commandScripts.enable = true;
      hyprlandControls.enable = true;
      nixShortcuts.enable = true;
    };
  };
}
