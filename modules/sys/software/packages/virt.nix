args:
let
  inherit (args) pkgs username;
in
{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
  users.users.${username}.extraGroups = [ "docker" "libvirtd" ];
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    spice-gtk
    usbredir
    libvirt-glib
  ];
}
