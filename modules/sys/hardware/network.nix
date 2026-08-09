args:
let
  inherit (args) host;
in
{
  networking = {
    networkmanager.enable = true;
    hostName = "${host}";
    firewall = {
      allowedTCPPorts = [ 5173 ];
      allowedUDPPorts = [ 5173 ];
    };
  };
}
