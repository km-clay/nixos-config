{ pkgs, username, ... }:
{
  imports = [ ./hardware.nix ];
  movOpts.softwareCfg.enableProfiles = [
    "base"
    "desktop"
    "virt"
    "gaming"
    "dev"
  ];

  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0664", GROUP="input"
  '';

  users.groups.davfs2 = { };
  users.users.${username}.extraGroups = [ "davfs2" ];

  security.polkit.enable = true;
}
