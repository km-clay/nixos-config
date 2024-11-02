{lib, config, username, ...}: {
  options = {
    virtOpts.enable = lib.mkEnableOption "enables virtualization";
  };
  config = lib.mkIf config.virtOpts.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
