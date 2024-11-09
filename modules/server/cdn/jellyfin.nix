{ pkgs, lib, config, ... }:

{
  options = {
    movOpts.jellyfinConfig.enable =
      lib.mkEnableOption "Enables the server's jellyfin config";
  };
  config = lib.mkIf config.movOpts.jellyfinConfig.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
