args:
let
  inherit (args) lib config movLib;
  cfg = config.movOpts.sysEnv;
  gated = cond: file: lib.mkIf cond (import file args);
in
{
  options.movOpts.sysEnv = {
    issue.enable        = movLib.mkDefaultOption "enables custom /etc/issue splash screen for the tty";
    nixSettings.enable  = movLib.mkDefaultOption "enables my nixos settings";
    stylixConfig.enable = movLib.mkDefaultOption "enables custom stylix options";
    sddmConfig.enable   = lib.mkEnableOption "enables custom sddm configuration";
  };

  config = lib.mkMerge [
    (gated cfg.issue.enable        ./issue.nix)
    (gated cfg.nixSettings.enable  ./nix.nix)
    (gated cfg.stylixConfig.enable ./stylix.nix)
    (gated cfg.sddmConfig.enable   ./sddm.nix)
  ];
}
