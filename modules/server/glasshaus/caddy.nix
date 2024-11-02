{ lib, config, pkgs, ... }:

{
  options = {
    caddyConfig.enable = lib.mkEnableOption "Enable my caddy config for the glasshaus.info domain name";
  };
  config = lib.mkIf config.caddyConfig.enable {
    services.caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" ''
        glasshaus.info {
          reverse_proxy localhost:8096
        }
      '';
    };
  };
}
