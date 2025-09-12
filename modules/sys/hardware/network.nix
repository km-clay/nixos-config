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
        "192.168.1.134" = [ "hosting.localhost" ];
        "192.168.1.140" = [ "panel.test" "dnsman.test" ];
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [ 443 8080 ];
        trustedInterfaces = [ "vnet9" "virbr0" "enp0s2" ];
      };
    };
  };
}
