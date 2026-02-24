{ lib, self, config, host, pkgs, ... }:

let
  scheme = "seti";
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
      targets = {
        waybar.enable = false;
        spicetify.enable = false;
        btop.enable = false;
        nixvim.enable = false;
        nixvim.transparentBackground = {
          main = false;
          signColumn = false;
        };
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.envy-code-r;
          name = "EnvyCodeR Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.myPkgs.noto-sans-jp;
          name = "Noto Sans JP";
        };
        serif = {
          package = pkgs.myPkgs.noto-sans-jp;
          name = "Noto Sans JP";
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
