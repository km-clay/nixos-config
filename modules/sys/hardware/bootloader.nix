args:
let
  inherit (args) pkgs;
in
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.configurationLimit = 10;
    loader.grub.gfxmodeEfi = "1024x768";
    loader.grub.extraConfig = ''
      GRUB_CMDLINE_LINUX_DEFAULT="nomodeset"
      GRUB_GFXPAYLOAD_LINUX=1024x768
    '';
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
