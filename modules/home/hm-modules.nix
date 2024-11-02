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

  hyprlandConfig.enable = lib.mkDefault true;
  autojumpOpts.enable = lib.mkDefault true;
  stylixHomeOpts.enable = lib.mkDefault true;
  waybarConfig.enable = lib.mkDefault true;
  gtkOpts.enable = lib.mkDefault true;
  spicetifyOpts.enable = lib.mkDefault true;
  starshipConfig.enable = lib.mkDefault true;
  btopConfig.enable = lib.mkDefault true;
  swayncConfig.enable = lib.mkDefault true;
  userPkgs.enable = lib.mkDefault true;
  cavaOpts.enable = lib.mkDefault true;
  ezaOpts.enable = lib.mkDefault true;
  firefoxConfig.enable = lib.mkDefault true;
  fuzzelConfig.enable = lib.mkDefault true;
  fzfOpts.enable = lib.mkDefault true;
  gitConfig.enable = lib.mkDefault true;
  kittyConfig.enable = lib.mkDefault true;
  yaziConfig.enable = lib.mkDefault true;
  zshConfig.enable = lib.mkDefault true;
  homeFiles.enable = lib.mkDefault true;
  passConfig.enable = lib.mkDefault true;
  batOpts.enable = lib.mkDefault true;

  pagedmovScripts.enable = lib.mkDefault true;
  pagedmovScripts.commandScripts.invoke.enable = lib.mkDefault true;
  pagedmovScripts.commandScripts.runbg.enable = lib.mkDefault true;
  pagedmovScripts.commandScripts.splash.enable = lib.mkDefault true;
  pagedmovScripts.commandScripts.toolbelt.enable = lib.mkDefault true;
  pagedmovScripts.commandScripts.viconf.enable = lib.mkDefault true;

  pagedmovScripts.hyprlandControls.chpaper.enable = lib.mkDefault true;
  pagedmovScripts.hyprlandControls.scheck.enable = lib.mkDefault true;
  pagedmovScripts.hyprlandControls.chscheme.enable = lib.mkDefault true;
  pagedmovScripts.hyprlandControls.keyring.enable = lib.mkDefault true;
  pagedmovScripts.hyprlandControls.moveonscreen.enable = lib.mkDefault true;
  pagedmovScripts.hyprlandControls.switchmon.enable = lib.mkDefault true;

  pagedmovScripts.nixShortcuts.garbage-collect.enable = lib.mkDefault true;
  pagedmovScripts.nixShortcuts.nsp.enable = lib.mkDefault true;
  pagedmovScripts.nixShortcuts.rebuild.enable = lib.mkDefault true;
}
