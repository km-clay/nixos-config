{ lib, config, pkgs, ... }:

{
  options = {
    movOpts.serverCfg.caddyConfig.enable = lib.mkEnableOption
      "Enable my caddy config for the glasshaus.info domain name";
  };
  config = lib.mkIf config.movOpts.serverCfg.caddyConfig.enable {
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
