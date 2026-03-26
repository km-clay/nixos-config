host:
{ username, pkgs, inputs, config, lib, ... }:
let
  shed = inputs.shed.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = lib.optionals (host != null) [ ./${host}/config.nix ];

  boot = {
    kernelModules = [ "acpi_call" ];
    extraModulePackages =
      with config.boot.kernelPackages;
      [
        acpi_call
        cpupower
      ]
      ++ [ pkgs.cpupower-gui ];
  };

  programs.shed.enable = lib.mkDefault true;

  environment = {
    variables = {
      PATH = lib.mkDefault "${pkgs.clang-tools}/bin:$PATH";
    };
    shells = lib.mkDefault (with pkgs; [
      shed
      zsh
      bash
    ]);
    systemPackages = with pkgs; [
      acpi
      brightnessctl
      cpupower-gui
      powertop
    ];
  };

  users = {
    groups.persist = { };
    users = {
      root.initialPassword = lib.mkDefault "1234";
      ${username} = {
        isNormalUser = lib.mkDefault true;
        initialPassword = lib.mkDefault "1234";
        shell = shed;
        extraGroups = [
          "wheel"
          "persist"
          "libvirtd"
        ];
      };
    };
  };
  security.sudo.extraConfig = lib.mkDefault ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = lib.mkDefault [ "@wheel" "${username}" ];

  movOpts.hardwareCfg = {
    bootLoader.enable    = lib.mkDefault true;
    networkModule.enable = lib.mkDefault true;
    kernelModule.enable  = lib.mkDefault true;
    powerProfiles.enable = lib.mkDefault true;
  };

  movOpts.sysEnv = {
    issue.enable        = lib.mkDefault true;
    nixSettings.enable  = lib.mkDefault true;
    stylixConfig.enable    = lib.mkDefault true;
    consoleSettings.enable = lib.mkDefault true;
    sddmConfig.enable      = lib.mkDefault false;
  };

  time.timeZone = lib.mkDefault "America/New_York";
}
