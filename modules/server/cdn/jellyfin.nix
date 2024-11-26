{ pkgs, lib, config, ... }:

{
  options = {
    movOpts.serverCfg.jellyfinConfig.enable =
      lib.mkEnableOption "Enables the server's jellyfin config";
  };
  config = lib.mkIf config.movOpts.serverCfg.jellyfinConfig.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
