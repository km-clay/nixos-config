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
  };
}
