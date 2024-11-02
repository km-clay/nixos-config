{lib, config, username, ...}: {
  options = {
    virtConfig.enable = lib.mkEnableOption "enables virtualization";
  };
  config = lib.mkIf config.virtConfig.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
