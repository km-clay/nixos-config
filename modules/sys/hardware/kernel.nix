{ lib, config, pkgs, ... }: {
  options = {
    movOpts.hardwareCfg.kernelModule.enable = lib.mkEnableOption "enables kernel module configuration";
  };
  config = lib.mkIf config.movOpts.hardwareCfg.kernelModule.enable {
    hardware.enableAllFirmware = true;
    environment.systemPackages = [
      pkgs.linux-firmware
    ];
    boot.kernelModules = [
      "amdgpu"
      "rtw89_8852ce"
    ];
  };
}
