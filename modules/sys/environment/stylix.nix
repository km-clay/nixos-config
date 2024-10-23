{
  pkgs,
	scheme,
	wallpaper,
  ...
}:

{
  stylix = {
    enable = true;
		base16Scheme = scheme;
    image = wallpaper;
    polarity = "dark";
    autoEnable = true;
		opacity.terminal = 0.5;
    targets = {
      console.enable = true;
      feh.enable = true;
      grub.enable = true;
			gtk.enable = true;
			nixos-icons.enable = true;
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrains Mono Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrains Mono Nerd Font";
      };
      serif = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrains Mono Nerd Font";
      };
			sizes = {
				desktop = 10;
				applications = 14;
				terminal = 14;
				popups = 12;
			};
    };
  };
}
