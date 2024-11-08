{lib, config, pkgs, ...}:

let
  cust-openrct2 = pkgs.openrct2.overrideAttrs (oldAttrs: {
        cmakeFlags = [
          "-DDOWNLOAD_OBJECTS=ON"
          "-DDOWNLOAD_OPENMSX=ON"
          "-DDOWNLOAD_OPENSFX=ON"
          "-DDOWNLOAD_TITLE_SEQUENCES=ON"
        ];
      });
in
{
  options = {
    movOpts.softwareCfg.gamingPkgs.enable = lib.mkEnableOption "enables gaming packages";
  };
  config = lib.mkIf config.movOpts.softwareCfg.gamingPkgs.enable {
    environment.systemPackages = with pkgs; [
      snes9x-gtk
      cust-openrct2
    ];
  };
}
