{ lib, pkgs, modulesPath, inputs, ... }:

let
  userConfig = {
    isNormalUser = true;
    initialPassword = "1234";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };
in
{
  imports = [ ./hardware.nix ];

  movOpts = {
    sysEnv = {
      issue.enable = true;
      stylixConfig.enable = true;
      nixSettings.enable = true;
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
  };

  users = {
    groups.persist = { };
    users = {
      impermanence = userConfig;
      persistence = userConfig // {
        extraGroups = userConfig.extraGroups ++ [ "persist" ];
      };
      root.initialPassword = "1234";
    };
  };
}
