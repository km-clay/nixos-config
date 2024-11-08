{pkgs, username, ...}: {
  imports = [
    ./hardware.nix
  ];

  # My module options
  movOpts = {
    sysEnv = {
      issue.enable = true;
      sddmConfig.enable = true;
      stylixConfig.enable = true;
      nixSettings.enable = true;
    };
    hardwareCfg = {
      networkModule.enable = true;
      bootLoader.enable = true;
    };
    softwareCfg = {
      gamingPkgs.enable = true;
      steamConfig.enable = true;
      sysPkgs.enable = true;
      sysProgs.enable = true;
      sysServices.enable = true;
      virtConfig.enable = true;
    };
  };

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

  users = {
    groups.persist = {};
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.zsh;
        extraGroups = ["wheel" "persist" "libvirtd"];
      };
    };
  };
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = ["${username}"];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
}
