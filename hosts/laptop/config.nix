{ pkgs, config, ... }: {
  imports = [ ./hardware.nix ./home.nix ];

  powerProfiles.enable = true;
  boot = {
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages;
      [ acpi_call cpupower ] ++ [ pkgs.cpupower-gui ];
  };

  networkModule.enable = true;
  nixSettings.enable = true;
  bootLoader.enable = true;
  issue.enable = true;
  sddmConfig.enable = true;
  stylixConfig.enable = true;
  sysPkgs.enable = true;
  sysProgs.enable = true;
  sysServices.enable = true;

  environment = {
    variables = { PATH = "${pkgs.clang-tools}/bin:$PATH"; };
    shells = with pkgs; [ zsh bash ];
    systemPackages = with pkgs; [ acpi brightnessctl cpupower-gui powertop ];
  };

}
