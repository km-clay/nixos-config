{ pkgs }:
pkgs.writeShellApplication {
  name = "nsp";
  text = ''
    trap 'NIX_SHELL=false kitty_theme' exit
    NIX_SHELL=true command nix-shell -p "$@" --run zsh
  '';
}
