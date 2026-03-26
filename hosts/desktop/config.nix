_:
{
  imports = [ ./hardware.nix ];
  movOpts.softwareCfg.enableProfiles = [
    "base"
    "desktop"
    "gaming"
    "dev"
    "virt"
  ];
}
