{
  host,
  inputs,
  username,
  nur,
  pkgs,
  self,
  ...
}: {
  imports = [
    ./../../modules/server
    ./settings.nix
    ./hardware.nix
  ];
}
