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

  environment = {
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
