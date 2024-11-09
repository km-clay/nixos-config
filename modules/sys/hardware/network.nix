{ host, lib, config, ... }: {
  options = {
    movOpts.hardwareCfg.networkModule.enable =
      lib.mkEnableOption "enables network configuration";
  };
  config = lib.mkIf config.movOpts.hardwareCfg.networkModule.enable {
    networking = {
      networkmanager.enable = true;
      hostName = "${host}";
      hosts = {
        "192.168.1.200" = [ "xenon" ];
        "192.168.1.201" = [ "oganesson" ];
        "192.168.1.202" = [ "mercury" ];
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [ 443 8080 ];
      };
    };
  };
}
