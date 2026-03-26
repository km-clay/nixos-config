_:
{
  imports = [ ./hardware.nix ];
  movOpts.softwareCfg.enableProfiles = [
    "desktop"
    "gaming"
    "dev"
  ];
}
