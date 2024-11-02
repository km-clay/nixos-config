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
    ./files
  ];

  # ./files
  homeFiles.enable = lib.mkDefault true;

  # ./environment
  hyprlandConfig.enable = lib.mkDefault true;
  autojumpConfig.enable = lib.mkDefault true;
  stylixHomeConfig.enable = lib.mkDefault true;
  waybarConfig.enable = lib.mkDefault true;
  gtkConfig.enable = lib.mkDefault true;
  spicetifyConfig.enable = lib.mkDefault true;
  starshipConfig.enable = lib.mkDefault true;

  # ./programs
  btopConfig.enable = lib.mkDefault true;
  swayncConfig.enable = lib.mkDefault true;
  userPkgs.enable = lib.mkDefault true;
  cavaConfig.enable = lib.mkDefault true;
  ezaConfig.enable = lib.mkDefault true;
  firefoxConfig.enable = lib.mkDefault true;
  fuzzelConfig.enable = lib.mkDefault true;
  fzfConfig.enable = lib.mkDefault true;
  gitConfig.enable = lib.mkDefault true;
  kittyConfig.enable = lib.mkDefault true;
  yaziConfig.enable = lib.mkDefault true;
  zshConfig.enable = lib.mkDefault true;
  passConfig.enable = lib.mkDefault true;
  batConfig.enable = lib.mkDefault true;

  # ./scripts
  movScripts.enable = lib.mkDefault true;
  movScripts.commandScripts.enable = lib.mkDefault true;
  movScripts.hyprlandControls.enable = lib.mkDefault true;
  movScripts.nixShortcuts.enable = lib.mkDefault true;
}
