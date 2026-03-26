args:
let
  inherit (args) lib config;
  cfg = config.movOpts.envConfig;
  gated = cond: file: lib.mkIf cond (import file args);
in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./spicetify.nix
    ./paperd
  ];

  options.movOpts.envConfig = {
    userPkgs.enable         = lib.mkEnableOption "my default user packages";
    stylixHomeConfig.enable = lib.mkEnableOption "my stylix Home-Manager options";
    gtkConfig.enable        = lib.mkEnableOption "my gtk options";
    starshipConfig.enable   = lib.mkEnableOption "my starship configuration";
    swayncConfig.enable     = lib.mkEnableOption "my swaync configuration";
    userServicesCli.enable       = lib.mkEnableOption "my headless user services";
    userServicesGraphical.enable = lib.mkEnableOption "my graphical user services";
    zshConfig = {
      shellAliases.enable = lib.mkEnableOption "my zsh aliases";
      envVariables.enable = lib.mkEnableOption "my default session variables";
      shellOptions.enable = lib.mkEnableOption "my default shell settings";
      extraConfig.enable  = lib.mkEnableOption "my extra shell configurations";
    };
    shedConfig = {
      shellAliases.enable = lib.mkEnableOption "my shed aliases";
      envVariables.enable = lib.mkEnableOption "my session variables";
      shellOptions.enable = lib.mkEnableOption "my default shed shopts";
      autoCmds.enable = lib.mkEnableOption "my shed autocmds";
      shellFunctions.enable = lib.mkEnableOption "my shed shell functions";
      keyMaps.enable = lib.mkEnableOption "my shed line editor keymaps";
      extraCompletion.enable = lib.mkEnableOption "extra shed completion scripts";
      extraConfig.enable = lib.mkEnableOption "my extra shed configuration";
    };
  };

  config = lib.mkMerge [
    (gated cfg.userPkgs.enable         ./userpkgs.nix)
    (gated cfg.stylixHomeConfig.enable ./stylixhome.nix)
    (gated cfg.gtkConfig.enable        ./gtk.nix)
    (gated cfg.starshipConfig.enable   ./starship.nix)
    (gated cfg.swayncConfig.enable     ./swaync.nix)
    (gated cfg.userServicesCli.enable       ./userservices-cli.nix)
    (gated cfg.userServicesGraphical.enable ./userservices-graphical.nix)

    # zsh
    (gated cfg.zshConfig.shellAliases.enable ./zsh/aliases.nix)
    (gated cfg.zshConfig.envVariables.enable ./zsh/env.nix)
    (gated cfg.zshConfig.shellOptions.enable ./zsh/options.nix)
    (gated cfg.zshConfig.extraConfig.enable  ./zsh/extraconfig.nix)

    # shed
    (gated cfg.shedConfig.shellAliases.enable ./shed/aliases.nix)
    (gated cfg.shedConfig.envVariables.enable ./shed/env.nix)
    (gated cfg.shedConfig.shellOptions.enable ./shed/options.nix)
    (gated cfg.shedConfig.extraConfig.enable  ./shed/extraconfig.nix)
    (gated cfg.shedConfig.shellFunctions.enable  ./shed/functions.nix)
    (gated cfg.shedConfig.autoCmds.enable  ./shed/autocmd.nix)
    (gated cfg.shedConfig.keyMaps.enable  ./shed/keymaps.nix)
    (gated cfg.shedConfig.extraCompletion.enable  ./shed/complete.nix)
  ];
}
