{
  inputs,
  nixpkgs,
  config,
  self,
  username,
  host,
  ...
}: {
  imports = [
    ./hardware
    ./software
    ./environment
    ../home/home-manager.nix
  ];
}
