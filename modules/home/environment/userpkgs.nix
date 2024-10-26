{
  pkgs,
  host,
  ...
}:
	let
  desktop = (host == "oganesson");
	extraFigletFonts = pkgs.fetchFromGitHub {
      owner = "xero";
      repo = "figlet-fonts";
      rev = "master";
      sha256 = "sha256-dAs7N66D2Fpy4/UB5Za1r2qb1iSAJR6TMmau1asxgtY=";
	};
	toilet-extrafonts = pkgs.toilet.overrideAttrs (oldAttrs: {
		buildInputs = oldAttrs.buildInputs or [] ++ [extraFigletFonts];

		installPhase = ''
			make install PREFIX=$out
			mkdir -p $out/share/figlet
			cp -r ${extraFigletFonts}/* $out/share/figlet
		'';
	});

  desktop_pkgs =
    if desktop
    then
      with pkgs; [
        uhk-agent
        zathura
        handbrake
        snes9x-gtk
        obs-studio
      ]
    else [];
in {
  home.packages = with pkgs;
    [
      chafa
			flavours
			ags
			sassc
      gtk3
      sqlite
      gimp
      imagemagick
      yt-dlp
      vlc
      lolcat
      speedtest-cli
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
    ]
    ++ desktop_pkgs;
}
