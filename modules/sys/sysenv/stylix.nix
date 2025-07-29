{ pkgs, self, lib, config, ... }:

let
  scheme = "ayu-dark";
  wallpaper = "${self}/assets/wallpapers/dark-waves.jpg";
in {
  options = {
    movOpts.sysEnv.stylixConfig.enable =
      lib.mkEnableOption "enables custom stylix options";
  };
  config = lib.mkIf config.movOpts.sysEnv.stylixConfig.enable {
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
      opacity.terminal = 0.8;
      targets = {
        console.enable = false;
        feh.enable = true;
        grub.enable = true;
        gtk.enable = true;
        nixos-icons.enable = true;
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
          package = pkgs.nerd-fonts.envy-code-r;
          name = "EnvyCodeR Nerd Font Mono";
        };
        serif = {
          package = pkgs.nerd-fonts.envy-code-r;
          name = "EnvyCodeR Nerd Font Mono";
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
