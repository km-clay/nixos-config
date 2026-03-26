args:
let
  inherit (args) pkgs;
in
{
  hardware.enableAllFirmware = true;
  environment.systemPackages = [
    pkgs.linux-firmware
  ];
  boot.kernelModules = [
    "amdgpu"
    "rtw89_8852ce"
  ];
}
