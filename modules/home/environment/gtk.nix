{lib, config, pkgs, ... }: {
  options = {
    gtkOpts.enable = lib.mkEnableOption "enable my gtk options";
  };
  config = lib.mkIf config.gtkOpts.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "CascadiaCode"
          "NerdFontsSymbolsOnly"
        ];
      })
    ];

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-nord.override {
          accent = "frostblue4";
        };
      };
      #cursorTheme = {
      #	name = "Bibata-Modern-Ice";
      #	package = pkgs.bibata-cursors;
      #	size = 16;
      #};
      #font = {
      #	name = "Iosevka Nerd Font";
      #	package = pkgs.nerdfonts.override {fonts = ["Iosevka"];};
      #};
    };
  };
}
