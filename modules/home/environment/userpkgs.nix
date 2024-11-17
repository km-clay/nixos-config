{ lib, config, pkgs, self, ... }:

let
  extraFigletFonts = pkgs.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "master";
    sha256 = "sha256-dAs7N66D2Fpy4/UB5Za1r2qb1iSAJR6TMmau1asxgtY=";
  };
  toilet-extrafonts = pkgs.toilet.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs or [ ] ++ [ extraFigletFonts ];

    installPhase = ''
      make install PREFIX=$out
      mkdir -p $out/share/figlet
      cp -r ${extraFigletFonts}/* $out/share/figlet
    '';
  });
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
      yubikey-manager
      yubikey-personalization
      gtk3
      sqlite
      gimp
      imagemagick
      vlc
      lolcat
      vesktop
      qbittorrent
      neovide
      zsh
      zsh-syntax-highlighting
      zsh-history-substring-search
      zsh-autosuggestions
      audacity
      rustup
      libreoffice
      gtrash
      ripgrep
      toilet-extrafonts
      python3
      chafa
    ] ++ scripts;
  };
}
