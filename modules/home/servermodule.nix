{ inputs, nixpkgs, config, self, username, host, lib, ... }: {
  imports = [
    ./environment/starship.nix
    ./environment/userpkgs.nix
    ./environment/zshell.nix
    ./programs/nixvim
    ./programs/autojump.nix
    ./programs/bat.nix
    ./programs/btop.nix
    ./programs/eza.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/yazi.nix
    ./scripts
  ];

  movOpts = {
    # ./environment
    zshConfig.enable = lib.mkDefault false;
    starshipConfig.enable = lib.mkDefault false;
    userPkgs.enable = lib.mkDefault false;

    # ./programs
    autojumpConfig.enable = lib.mkDefault false;
    btopConfig.enable = lib.mkDefault false;
    ezaConfig.enable = lib.mkDefault false;
    fzfConfig.enable = lib.mkDefault false;
    gitConfig.enable = lib.mkDefault false;
    yaziConfig.enable = lib.mkDefault false;
    batConfig.enable = lib.mkDefault false;

    # ./scripts
    movScripts.enable = lib.mkDefault false;
    movScripts.commandScripts.enable = lib.mkDefault false;
    movScripts.hyprlandControls.enable = lib.mkDefault false;
    movScripts.nixShortcuts.enable = lib.mkDefault false;
  };
}
