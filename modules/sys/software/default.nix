args:
let
  inherit (args) config movLib;
in
movLib.mkProfileOptions {
  inherit args config;
  modName = "softwareCfg";
  profileModules = {
    base    = ./profiles/base.nix;
    desktop = ./profiles/desktop.nix;
    dev     = ./profiles/dev.nix;
    gaming  = ./profiles/gaming.nix;
    virt    = ./profiles/virt.nix;
  };
}
