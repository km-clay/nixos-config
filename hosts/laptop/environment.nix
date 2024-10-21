{pkgs, ...}: {
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
}
