{pkgs, lib, config, ...}: {
  options = {
    # make this enabled by default!!!
    bootLoader.enable = lib.mkEnableOption "enables bootloader config";
  };
  config = lib.mkIf config.bootLoader.enable {
    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot.configurationLimit = 10;
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
