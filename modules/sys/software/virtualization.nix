{
  lib,
  config,
  username,
  pkgs,
  ...
}:
{
  options = {
    movOpts.softwareCfg.virtConfig.enable = lib.mkEnableOption "enables virtualization";
  };
  config = lib.mkIf config.movOpts.softwareCfg.virtConfig.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      spice-gtk
      usbredir
    ];
  };
}
