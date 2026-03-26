args:
let
  inherit (args) pkgs;
  scheme = "ayu-dark";
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
    polarity = "dark";
    autoEnable = true;
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
}
