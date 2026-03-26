args:
let
  inherit (args) lib config movLib;
  cfg = config.movOpts.sysEnv;
  gated = cond: file: lib.mkIf cond (import file args);
in
{
  imports = [ ./console.nix ];

  options.movOpts.sysEnv = {
    issue.enable        = lib.mkEnableOption "enables custom /etc/issue splash screen for the tty";
    nixSettings.enable  = lib.mkEnableOption "enables my nixos settings";
    stylixConfig.enable = lib.mkEnableOption "enables custom stylix options";
    sddmConfig.enable   = lib.mkEnableOption "enables custom sddm configuration";
  };

  config = lib.mkMerge [
    (gated cfg.issue.enable        ./issue.nix)
    (gated cfg.nixSettings.enable  ./nix.nix)
    (gated cfg.stylixConfig.enable ./stylix.nix)
    (gated cfg.sddmConfig.enable   ./sddm.nix)
  ];
}
