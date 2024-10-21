{
  host,
  inputs,
  pkgs,
  config,
  self,
  username,
  ...
}: {
  imports = [
    ./../../modules/sys/configuration.nix
    ./hardware.nix
    ./boot.nix
    ./services.nix
    ./environment.nix
    ./settings.nix
  ];
}
