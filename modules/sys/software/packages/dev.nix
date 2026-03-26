args:
let
  inherit (args) pkgs;
in
{
  environment.systemPackages = with pkgs; [
    dotnetCorePackages.sdk_8_0_4xx
    myPython
    ffmpeg
    cmake
    gnumake
    pkg-config
    openssl
  ];
}
