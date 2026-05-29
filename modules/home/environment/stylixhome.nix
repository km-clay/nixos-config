args:
let
  inherit (args) pkgs;
  scheme = "ayu-dark";
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    polarity = "dark";
    autoEnable = true;
    targets = {
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
        package = pkgs.maple-mono.truetype-autohint;
        name = "Maple Mono";
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
}
