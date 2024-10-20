{
  pkgs,
  config,
  ...
}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
		(nerdfonts.override { fonts = [
			"JetBrainsMono"
			"CascadiaCode"
			"NerdFontsSymbolsOnly"
		]; })
  ];

  gtk = {
    enable = true;
		cursorTheme = {
			name = "Bibata-Modern-Ice";
			package = pkgs.bibata-cursors;
			size = 16;
		};
	#font = {
	#	name = "Iosevka Nerd Font";
	#	package = pkgs.nerdfonts.override {fonts = ["Iosevka"];};
	#};
  };
}
