{lib, config, username, ...}: {
  options = {
    movOpts.softwareCfg.virtConfig.enable = lib.mkEnableOption "enables virtualization";
  };
  config = lib.mkIf config.movOpts.softwareCfg.virtConfig.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
