{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];
  movOpts.softwareCfg.enableProfiles = [
    "base"
    "desktop"
    "gaming"
    "dev"
    "virt"
  ];

  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0664", GROUP="input"
  '';

  users.groups.davfs2 = { };
  users.users.pagedmov.extraGroups = [ "davfs2" ];

  security.polkit.enable = true;
}
