args:
let
  inherit (args) host;
in
{
  networking = {
    networkmanager.enable = true;
    hostName = "${host}";
  };
}
