{ lib, config, pkgs, ... }: {
  options = {
    movOpts.envConfig.gtkConfig.enable =
      lib.mkEnableOption "enable my gtk options";
  };
  config = lib.mkIf config.movOpts.envConfig.gtkConfig.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs;
      [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
        cascadia-code
      ];

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-nord.override { accent = "frostblue4"; };
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
