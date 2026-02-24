{ inputs, pkgs, username, ... }:

let
  shed = inputs.shed.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./hardware.nix
  ];

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
      kernelModule.enable = true;
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

  programs.shed.enable = true;

  users = {
    groups.persist = { };
    groups.davfs2 = { };
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.shed;
        extraGroups = [ "davfs2" "input" "wheel" "persist" "libvirtd" ];
      };
    };
  };
  security.polkit.enable = true;
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = [ "${username}" ];

  time.timeZone = "America/New_York";
}
