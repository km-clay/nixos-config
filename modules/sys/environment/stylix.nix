{
  pkgs,
  self,
  lib,
  config,
  ...
}:

let
  scheme = "tokyo-night-dark";
  wallpaper = "${self}/assets/wallpapers/dark-waves.jpg";
in
{
  options = {
    movOpts.stylixConfig.enable = lib.mkEnableOption "enables custom stylix options";
  };
  config = lib.mkIf config.movOpts.stylixConfig.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
      image = wallpaper;
      homeManagerIntegration = {
        autoImport = true;
        followSystem = true;
      };
      polarity = "dark";
      autoEnable = true;
      opacity.terminal = 0.50;
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
          popups = 16;
        };
      };
    };
  };
}
