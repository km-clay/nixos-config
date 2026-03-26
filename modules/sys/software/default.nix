args:
let
  inherit (args) lib config;
  cfg = config.movOpts.softwareCfg;
  gated = cond: file: lib.mkIf cond (import file args);
in
{
  imports = [
    ./profiles/options.nix
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/dev.nix
    ./profiles/gaming.nix
    ./profiles/virt.nix
  ];

  options.movOpts.softwareCfg = {
    basePackages.enable      = lib.mkEnableOption "base system packages and services";
    desktopPackages.enable   = lib.mkEnableOption "desktop environment packages and services";
    devPackages.enable       = lib.mkEnableOption "development tools and SDKs";
    gamingPackages.enable    = lib.mkEnableOption "gaming packages and Steam";
    virtPackages.enable      = lib.mkEnableOption "virtualization tools";
  };

  config = lib.mkMerge [
    (gated cfg.basePackages.enable    ./packages/base.nix)
    (gated cfg.desktopPackages.enable ./packages/desktop.nix)
    (gated cfg.devPackages.enable     ./packages/dev.nix)
    (gated cfg.gamingPackages.enable  ./packages/gaming.nix)
    (gated cfg.virtPackages.enable    ./packages/virt.nix)
  ];
}
