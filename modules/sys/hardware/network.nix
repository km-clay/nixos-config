{host, lib, config, ...}:
{
  options = {
    networkModule.enable = lib.mkEnableOption "enables network configuration";
  };
  config = lib.mkIf config.networkModule.enable {
    networking = {
      networkmanager.enable = true;
      hostName = "${host}";
      hosts = {
        "192.168.1.200" = ["xenon"];
        "192.168.1.201" = ["oganesson"];
        "192.168.1.223" = ["mercury"];
      };
      firewall = {
        enable = true;
      };
    };
  };
}
