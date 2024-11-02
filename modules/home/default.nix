{
  inputs,
  nixpkgs,
  config,
  self,
  username,
  host,
  lib,
  ...
}: {
  imports = [
    ./programs
    ./environment
    ./scripts
    ./files.nix
  ];

  # ./files
  homeFiles.enable = lib.mkDefault false;

  # ./environment
  hyprlandConfig.enable = lib.mkDefault false;
  autojumpConfig.enable = lib.mkDefault false;
  stylixHomeConfig.enable = lib.mkDefault false;
  waybarConfig.enable = lib.mkDefault false;
  gtkConfig.enable = lib.mkDefault false;
  spicetifyConfig.enable = lib.mkDefault false;
  starshipConfig.enable = lib.mkDefault false;

  # ./programs
  btopConfig.enable = lib.mkDefault false;
  swayncConfig.enable = lib.mkDefault false;
  userPkgs.enable = lib.mkDefault false;
  cavaConfig.enable = lib.mkDefault false;
  ezaConfig.enable = lib.mkDefault false;
  firefoxConfig.enable = lib.mkDefault false;
  fuzzelConfig.enable = lib.mkDefault false;
  fzfConfig.enable = lib.mkDefault false;
  gitConfig.enable = lib.mkDefault false;
  kittyConfig.enable = lib.mkDefault false;
  yaziConfig.enable = lib.mkDefault false;
  zshConfig.enable = lib.mkDefault false;
  passConfig.enable = lib.mkDefault false;
  batConfig.enable = lib.mkDefault false;

  # ./scripts
  movScripts.enable = lib.mkDefault false;
  movScripts.commandScripts.enable = lib.mkDefault false;
  movScripts.hyprlandControls.enable = lib.mkDefault false;
  movScripts.nixShortcuts.enable = lib.mkDefault false;
}
