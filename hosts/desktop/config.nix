{ slash, pkgs, username, ... }:

{
  imports = [ ./hardware.nix ];

  # My module options
  movOpts = {
    sysEnv = {
      issue.enable = true;
      sddmConfig.enable = false;
      stylixConfig.enable = true;
      nixSettings.enable = true;
      #consoleSettings.enable = true;
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

  environment = {
    variables = { PATH = "${pkgs.clang-tools}/bin:$PATH"; };
    shells = [ pkgs.myPkgs.slash pkgs.zsh pkgs.bash ];
  };

  users = {
    groups.persist = { };
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.zsh;
        extraGroups = [ "input" "wheel" "persist" "libvirtd" ];
      };
    };
  };
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = [ "${username}" ];

  time.timeZone = "America/New_York";
}
