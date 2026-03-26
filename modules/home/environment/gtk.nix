args:
let
  inherit (args) pkgs config;
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    cascadia-code
  ];

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-nord.override { accent = "frostblue4"; };
    };
  };
}
