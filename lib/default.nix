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
    inherit mkOverrideOption foldHosts;
  };
  mkHost = (import ./mk_host.nix) movLib;
  mkProfileOptions = { args, config, modName, profileModules }:
  let
    cfg = config.movOpts.${modName};
    profileNames = builtins.attrNames profileModules;
    isEnabled = name:
      builtins.elem name cfg.enableProfiles
      || (cfg.profiles.${name}.enable or false);
    getOverride = name:
      cfg.profiles.${name}.override or (x: x);
    profileConfigs = map (name:
      lib.mkIf (isEnabled name) (
        (getOverride name) (import profileModules.${name} args)
      )
    ) profileNames;
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
