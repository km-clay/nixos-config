args:
let
  inherit (args) pkgs;
in
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    spice-gtk
    usbredir
    libvirt-glib
  ];
}
