args:
let
  inherit (args) pkgs;
  cust-openrct2 = pkgs.openrct2.overrideAttrs (oldAttrs: {
    cmakeFlags = [
      "-DDOWNLOAD_OBJECTS=ON"
      "-DDOWNLOAD_OPENMSX=ON"
      "-DDOWNLOAD_OPENSFX=ON"
      "-DDOWNLOAD_TITLE_SEQUENCES=ON"
    ];
  });
  cust-prismlauncher = pkgs.prismlauncher.override (oldAttrs: {
    jdks = [ pkgs.temurin-bin-21 ];
  });
in
{
  environment.systemPackages = with pkgs; [
    #snes9x-gtk
    #cust-openrct2
    mgba
    shadps4
    cust-prismlauncher
  ];
}
