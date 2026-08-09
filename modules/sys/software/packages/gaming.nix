args:
let
  inherit (args) pkgs;
  cust-prismlauncher = pkgs.prismlauncher.override (oldAttrs: {
    jdks = [ pkgs.temurin-bin-21 ];
  });
in
{
  environment.systemPackages = with pkgs; [
    mgba
    shadps4
    cust-prismlauncher
    rcon-cli
    myPkgs.tetrio
    dolphin-emu
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
