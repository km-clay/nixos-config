{
  inputs,
  nixpkgs,
  config,
  self,
  username,
  host,
  lib,
  ...
}: {
  imports = [
    ./hardware
    ./software
    ./environment
  ];

  networkModule.enable = lib.mkDefault false;
  nixSettings.enable = lib.mkDefault false;
  bootLoader.enable = lib.mkDefault false;
  issue.enable = lib.mkDefault false;
  sddmConfig.enable = lib.mkDefault false;
  stylixConfig.enable = lib.mkDefault false;
  gamingPkgs.enable = lib.mkDefault false;
  steamConfig.enable = lib.mkDefault false;
  sysPkgs.enable = lib.mkDefault false;
  sysProgs.enable = lib.mkDefault false;
  sysServices.enable = lib.mkDefault false;
  virtConfig.enable = lib.mkDefault false;
  powerProfiles.enable = lib.mkDefault false;
}
