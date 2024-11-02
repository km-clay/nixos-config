{lib, config, pkgs, ...}: {
  options = {
    gamingPkgs.enable = lib.mkEnableOption "enables gaming packages";
  };
  config = lib.mkIf config.gamingPkgs.enable {
    environment.systemPackages = with pkgs; [
      snes9x-gtk
    ];
  };
}
