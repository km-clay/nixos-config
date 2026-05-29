args:
let
  inherit (args) pkgs;
in
{
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      grub = {
        device = "nodev";
        enable = true;
        efiSupport = true;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
