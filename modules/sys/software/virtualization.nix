{lib, config, username, ...}: {
  options = {
    movOpts.virtConfig.enable = lib.mkEnableOption "enables virtualization";
  };
  config = lib.mkIf config.movOpts.virtConfig.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
