{ lib, movLib, ... }:
{
  options.movOpts.softwareCfg = {
    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "enable this profile";
          override = movLib.mkOverrideOption "override function for this profile's config";
        };
      });
      default = {};
    };
    enableProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "a list of profile names to enable";
    };
  };
}
