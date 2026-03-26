{
  inputs,
  username,
  nixpkgsConfig ? {
    allowUnfree = true;
  },
}:

let
  inherit (inputs.nixpkgs) lib;
in
rec {
  movLib = {
    inherit mkOverrideOption mkProfileOptions foldHosts;
  };
  mkHost = (import ./mk_host.nix) movLib;
  mkProfileOptions = { args, config, modName, profileModules }:
  let
    cfg = config.movOpts.${modName};
    shorthand = lib.genAttrs cfg.enableProfiles (_: { enable = true; });
    merged = lib.recursiveUpdate shorthand cfg.profiles;
    activeProfiles = lib.filterAttrs (_: pcfg: pcfg.enable) merged;

    profileConfigs = lib.mapAttrsToList (name: pcfg:
      pcfg.override (import profileModules.${name} args)
    ) activeProfiles;
  in
  {
    options.movOpts.${modName} = {
      profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "enable this profile";
            override = mkOverrideOption "override function for this profile's config";
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
    config = lib.mkMerge profileConfigs;
  };
  mkOverrideOption = description: lib.mkOption {
    inherit description;
    type = lib.types.functionTo lib.types.attrs;
    default = x: x;
  };
  foldHosts =
    hosts:
    lib.foldl'
      (
        acc: host:
        let
          result = mkHost ({ inherit inputs username nixpkgsConfig; } // host);
        in
        {
          nixosConfigurations = acc.nixosConfigurations // result.nixosConfigurations;
          homeConfigurations = acc.homeConfigurations // result.homeConfigurations;
        }
      )
      {
        nixosConfigurations = { };
        homeConfigurations = { };
      }
      hosts;
}
