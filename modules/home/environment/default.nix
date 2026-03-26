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
    ./shed
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
  };

  config = lib.mkMerge [
    (gated cfg.userPkgs.enable         ./userpkgs.nix)
    (gated cfg.stylixHomeConfig.enable ./stylixhome.nix)
    (gated cfg.gtkConfig.enable        ./gtk.nix)
    (gated cfg.starshipConfig.enable   ./starship.nix)
    (gated cfg.swayncConfig.enable     ./swaync.nix)
    (gated cfg.zshConfig.shellAliases.enable ./zsh/aliases.nix)
    (gated cfg.zshConfig.envVariables.enable ./zsh/env.nix)
    (gated cfg.zshConfig.shellOptions.enable ./zsh/options.nix)
    (gated cfg.zshConfig.extraConfig.enable  ./zsh/extraconfig.nix)
    (gated cfg.userServicesCli.enable       ./userservices-cli.nix)
    (gated cfg.userServicesGraphical.enable ./userservices-graphical.nix)
  ];
}
