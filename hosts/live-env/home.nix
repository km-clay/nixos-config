{ pkgs, username, ... }:

let
  scripts = with pkgs; [
    myScripts.icanhazip
    myScripts.invoke
    myScripts.runbg
    myScripts.splash
    myScripts.toolbelt
    myScripts.viconf
    myScripts.vipkg
    myScripts.fetchfromgh
    myScripts.garbage-collect
    myScripts.nsp
    myScripts.rebuild
    myScripts.chpaper
    myScripts.chscheme
    myScripts.keyring
    myScripts.mkscreenshots
    myScripts.moveonscreen
    myScripts.s_check
    myScripts.switchmon
    myScripts.git-compose
    myScripts.playshellsound
    myScripts.color-commit
  ];
in
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nemo
    feh
    gtk3
    sqlite
    gimp
    imagemagick
    lolcat
    vesktop
    zsh
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-autosuggestions
    libreoffice
    gtrash
    ripgrep
    toilet-extrafonts
    chafa
  ] ++ scripts;

  movOpts = {
    homeFiles.enable = true;
    envConfig = {
      hyprlandConfig = {
        enable = true;
        monitorNames = [ "eDP-1" ];
        workspaceLayout = "singlemonitor";
      };
      userPkgs.enable = false;
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
