{ inputs, lib, config, pkgs, self, ... }:

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
    myScripts.mkshell
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
  pythonWithStuff = pkgs.python3.withPackages(ps: with ps; [ requests ]);
in {
  options = {
    movOpts.envConfig.userPkgs.enable =
      lib.mkEnableOption "enables my default user packages";
  };
  config = lib.mkIf config.movOpts.envConfig.userPkgs.enable {
    home.packages = with pkgs; [
      cargo
      rustc
      clippy
      rust-analyzer
      nerd-fonts.envy-code-r
      clippy
      rust-analyzer
      nemo
      feh
      gtk3
      vicut
      imagemagick
      vlc
      lolcat
      vesktop
      zsh
      zsh-syntax-highlighting
      zsh-history-substring-search
      zsh-autosuggestions
      #libreoffice
      gtrash
      ripgrep
      wf-recorder
      toilet
      vkbasalt
      firefox
      spotify
      zathura
      tor
      tor-browser
      chromium
      obs-studio
      gparted
      dust
      porsmo
      w3m
      sox
      neovide
      claude-code
      pythonWithStuff
      monero-cli
      protonup-qt
      piper
      libratbag
      ghostty
      firefox
      fd
      delta
      glfw
      mesa-demos
      xwayland
      discord
      cloc
      wine
      gimp
      fira-code
      nerd-fonts.fira-code
      nodejs_latest
      myPkgs.noto-sans-jp
      myPkgs.billy-font
    ] ++ scripts;
  };
}
