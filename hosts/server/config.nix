{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./hardware.nix
    ./home.nix
  ];
  nixSettings.enable = true;
  networkModule.enable = true;
  bootLoader.enable = true;
  issue.enable = true;
  sysPkgs.enable = true;
  sysProgs.enable = true;
  sysServices.enable = true;
  jellyfinConfig.enable = true;
  caddyConfig.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
  };
  environment = {
    etc."tmpfiles.d/home-permissions.conf".text = ''
      d /home/pagedmov 0750 pagedmov users -
    '';
    variables = {
      PATH = "${pkgs.clang-tools}/bin:$PATH";
      TERM = "kitty";
    };
    shells = with pkgs; [
      zsh
      bash
    ];
  };
}
