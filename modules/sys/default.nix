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
}
