args:
let
  inherit (args) lib config movLib;
  cfg = config.movOpts.hardwareCfg;
  gated = cond: file: lib.mkIf cond (import file args);
in
{
  options.movOpts.hardwareCfg = {
    bootLoader.enable    = movLib.mkDefaultOption "enables bootloader config";
    networkModule.enable = movLib.mkDefaultOption "enables network configuration";
    kernelModule.enable  = movLib.mkDefaultOption "enables kernel module configuration";
    powerProfiles.enable = movLib.mkDefaultOption "enables power profiles";
  };

  config = lib.mkMerge [
    (gated cfg.bootLoader.enable    ./bootloader.nix)
    (gated cfg.networkModule.enable ./network.nix)
    (gated cfg.kernelModule.enable  ./kernel.nix)
    (gated cfg.powerProfiles.enable ./powerprofiles.nix)
    (import ./input.nix args)
    { hardware.keyboard.uhk.enable = true; }
  ];
}
