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
    ./sys/hardware
    ./sys/software
    ./sys/environment
    ./home/home-manager.nix
  ];

  networkModule.enable = lib.mkDefault true;
  nixSettings.enable = lib.mkDefault true;
  bootLoader.enable = lib.mkDefault true;
  issue.enable = lib.mkDefault true;
  sddmOpts.enable = lib.mkDefault true;
  stylixOpts.enable = lib.mkDefault true;
  gamingPkgs.enable = lib.mkDefault true;
  steamOpts.enable = lib.mkDefault true;
  sysPkgs.enable = lib.mkDefault true;
  sysProgs.enable = lib.mkDefault true;
  sysServices.enable = lib.mkDefault true;
  virtOpts.enable = lib.mkDefault true;
  powerProfiles.enable = lib.mkDefault false;
}
