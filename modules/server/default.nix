{ pkgs, lib, ... }:

{
  imports = [ ./cdn ./glasshaus ];
  movOpts = {
    jellyfinConfig.enable = lib.mkDefault false;
    caddyConfig.enable = lib.mkDefault false;
  };
}
