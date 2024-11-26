{ lib, self, config, host, pkgs, ... }:

let
  scheme = "tokyo-night-dark";
  wallpaper = "${self}/assets/wallpapers/dark-waves.jpg";
  server = (host == "xenon");
in {
  options = {
    movOpts.envConfig.stylixHomeConfig.enable =
      lib.mkEnableOption "enables my stylix Home-Manager options";
  };
  config = lib.mkIf config.movOpts.envConfig.stylixHomeConfig.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
      image = wallpaper;
      polarity = "dark";
      autoEnable = true;
      opacity.terminal = 0.5;
      targets = {
        waybar.enable = false;
        btop.enable = false;
        nixvim.transparentBackground = {
          main = false;
          signColumn = false;
        };
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
      fonts = {
        monospace = {
          package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
          name = "JetBrains Mono Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
          name = "JetBrains Mono Nerd Font";
        };
        serif = {
          package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
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
