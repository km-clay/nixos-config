{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./home.nix
  ];

  # My module options
  networkModule.enable = true;
  nixSettings.enable = true;
  bootLoader.enable = true;
  issue.enable = true;
  sddmConfig.enable = true;
  stylixConfig.enable = true;
  gamingPkgs.enable = true;
  steamConfig.enable = true;
  sysPkgs.enable = true;
  sysProgs.enable = true;
  sysServices.enable = true;
  virtConfig.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = ["https://nix-gaming.cachix.org"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    variables = {
      PATH = "${pkgs.clang-tools}/bin:$PATH";
    };
    shells = with pkgs; [
      zsh
      bash
    ];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
}
