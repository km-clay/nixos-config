{ pkgs, lib, config, ... }: {
  options = {
    movOpts.hardwareCfg.bootLoader.enable =
      lib.mkEnableOption "enables bootloader config";
  };
  config = lib.mkIf config.movOpts.hardwareCfg.bootLoader.enable {
    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot.configurationLimit = 10;
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
