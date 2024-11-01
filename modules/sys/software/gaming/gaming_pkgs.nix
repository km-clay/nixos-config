{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    snes9x-gtk
  ];
}
