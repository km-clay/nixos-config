{ lib, config, self, ... }:

{
  imports = [
    ./env.nix
    ./aliases.nix
    ./options.nix
    ./extraconfig.nix
  ];
}
