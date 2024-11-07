{ pkgs, lib, config, ... }:

{
  options = {
    jellyfinConfig.enable = lib.mkEnableOption "Enables the server's jellyfin config";
  };
  config = lib.mkIf config.movOpts.jellyfinConfig.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
