{pkgs, config, ...}: {
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  imports = [ ./hardware.nix ];

  powerProfiles.enable = true;
  boot = {
    kernelModules = ["acpi_call"];
    extraModulePackages = with config.boot.kernelPackages;
      [
        acpi_call
        cpupower
      ]
      ++ [pkgs.cpupower-gui];
  };

    environment = {
      variables = {
        PATH = "${pkgs.clang-tools}/bin:$PATH";
      };
      shells = with pkgs; [
        zsh
        bash
      ];
      systemPackages = with pkgs; [
        acpi
        brightnessctl
        cpupower-gui
        powertop
      ];
    };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

}
