{ lib, config, pkgs, self, ... }:

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
    myScripts.mntstack
  ];
in {
  options = {
    movOpts.envConfig.userPkgs.enable =
      lib.mkEnableOption "enables my default user packages";
  };
  config = lib.mkIf config.movOpts.envConfig.userPkgs.enable {
    home.packages = with pkgs; [
      nemo
      feh
      gtk3
      gimp
      imagemagick
      vlc
      lolcat
      vesktop
      zsh
      zsh-syntax-highlighting
      zsh-history-substring-search
      zsh-autosuggestions
      libreoffice
      gtrash
      ripgrep
      wf-recorder
      toilet
      vkbasalt
    ] ++ scripts;
  };
}
