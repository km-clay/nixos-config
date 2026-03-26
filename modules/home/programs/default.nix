args:
let
  inherit (args) lib config;
  cfg = config.movOpts.programConfigs;
  gated = cond: file: lib.mkIf cond (import file args);
in
{
  imports = [
    ./nixvim
  ];

  options.movOpts.programConfigs = {
    autojumpConfig.enable = lib.mkEnableOption "my autojump options";
    batConfig.enable      = lib.mkEnableOption "my bat options";
    btopConfig.enable     = lib.mkEnableOption "my btop config";
    ezaConfig.enable      = lib.mkEnableOption "my eza options";
    fuzzelConfig.enable   = lib.mkEnableOption "my fuzzel configuration";
    fzfConfig.enable      = lib.mkEnableOption "my fzf options";
    gitConfig.enable      = lib.mkEnableOption "my git configuration";
    kittyConfig.enable    = lib.mkEnableOption "my kitty configuration";
    passConfig.enable     = lib.mkEnableOption "my pass config";
    yaziConfig.enable     = lib.mkEnableOption "my yazi config";
    cavaConfig.enable     = lib.mkEnableOption "my cava settings";
  };

  config = lib.mkMerge [
    (gated cfg.autojumpConfig.enable ./autojump.nix)
    (gated cfg.batConfig.enable      ./bat.nix)
    (gated cfg.btopConfig.enable     ./btop.nix)
    (gated cfg.ezaConfig.enable      ./eza.nix)
    (gated cfg.fuzzelConfig.enable   ./fuzzel.nix)
    (gated cfg.fzfConfig.enable      ./fzf.nix)
    (gated cfg.gitConfig.enable      ./git.nix)
    (gated cfg.kittyConfig.enable    ./kitty.nix)
    (gated cfg.passConfig.enable     ./password-store.nix)
    (gated cfg.yaziConfig.enable     ./yazi.nix)
    (gated cfg.cavaConfig.enable     ./cava.nix)
  ];
}
