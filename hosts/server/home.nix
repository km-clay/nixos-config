{ host, pkgs, self, inputs, lib, username, config, ... }: {

  home.username = "${username}"; # Replace with your actual username
  home.homeDirectory =
    "/home/${username}"; # Replace with your actual home directory
  home.stateVersion =
    "24.05"; # Adjust this based on your system's NixOS version

  programs.home-manager.enable = true;

  movOpts = {
    # modules/home/environment
    autojumpConfig.enable = true;
    starshipConfig.enable = true;
    zshConfig.enable = true;

    # modules/home/programs
    btopConfig.enable = true;
    userPkgs.enable = true;
    ezaConfig.enable = true;
    fzfConfig.enable = true;
    gitConfig.enable = true;
    yaziConfig.enable = true;
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
