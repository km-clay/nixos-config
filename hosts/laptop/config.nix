_:
{
  imports = [ ./hardware.nix ];
  movOpts.softwareCfg.enableProfiles = [
    "base"
    "desktop"
    "dev"
  ];
}
