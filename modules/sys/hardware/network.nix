{host, lib, config, ...}: let
  desktop = host == "oganesson";
in {
  options = {
    networkModule.enable = lib.mkEnableOption "enables network configuration";
  };
  config = lib.mkIf config.networkModule.enable {
    networking = {
      networkmanager.enable = true;
      hostName =
        if desktop
        then "oganesson"
        else "mercury";
      hosts = {
        "192.168.1.201" = ["xenon"];
        "192.168.1.111" = ["argon"];
        "192.168.1.223" = ["mercury"];
      };
      firewall = {
        enable = true;
      };
    };
  };
}
