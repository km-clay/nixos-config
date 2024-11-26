{ pkgs, username, ... }: {
  imports = [ ./hardware.nix ];
  movOpts = {
    sysEnv = {
      nixSettings.enable = true;
      issue.enable = true;
    };
    hardwareCfg = {
      networkModule.enable = true;
      bootLoader.enable = true;
    };
    softwareCfg = {
      sysPkgs.enable = true;
      sysProgs.enable = true;
      sysServices.enable = true;
    };
    serverCfg = {
      jellyfinConfig.enable = true;
      caddyConfig.enable = true;
    };
  };
  networking.firewall = { allowedTCPPorts = [ 443 8920 ]; };
  environment = {
    etc."tmpfiles.d/home-permissions.conf".text = ''
      d /home/pagedmov 0750 pagedmov users -
    '';
    variables = {
      PATH = "${pkgs.clang-tools}/bin:$PATH";
      TERM = "kitty";
    };
    shells = with pkgs; [ zsh bash ];
  };

  users = {
    groups.persist = { };
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "persist" "libvirtd" ];
      };
    };
  };
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = [ "${username}" ];

  time.timeZone = "America/New_York";
}
