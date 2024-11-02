{ pkgs, lib, ... }:

{
  imports = [
    ./cdn
    ./glasshaus
  ];

  jellyfinConfig.enable = lib.mkDefault false;
  caddyConfig.enable = lib.mkDefault false;
}
