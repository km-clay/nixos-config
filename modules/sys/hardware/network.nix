{
  host,
  lib,
  config,
  ...
}:
{
  options = {
    movOpts.hardwareCfg.networkModule.enable = lib.mkEnableOption "enables network configuration";
  };
  config = lib.mkIf config.movOpts.hardwareCfg.networkModule.enable {
    networking = {
      networkmanager.enable = true;
      hostName = "${host}";
      firewall = {
        enable = true;
        allowedTCPPorts = [
          443
          8080
        ];
        allowedUDPPorts = [ 27960 ];
        trustedInterfaces = [
          "vnet9"
          "virbr0"
          "enp0s2"
        ];
      };
    };
  };
}
