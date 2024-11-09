{ pkgs ? import <nixpkgs> { } }:
let
  nixpkgs_toplevel = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "63dacb46bf939521bdc93981b4cbb7ecb58427a0";
    hash = "sha256-vboIEwIQojofItm2xGCdZCzW96U85l9nDW3ifMuAIdM=";
  };
in pkgs.writeShellApplication {
  name = "vipkg";
  runtimeInputs = with pkgs; [ coreutils fd ripgrep fzf ];
  text = ''
    [ ! $# -eq 1 ] && echo "Usage: vipkg <nixpkgs package name>" && exit 1

    results=$(find "${nixpkgs_toplevel}/pkgs" -wholename "*$1*" -exec find {} \; | sort | uniq | rg '\.nix$')
    numresults=$(echo "$results" | wc -l)

    [ "$numresults" -eq 0 ] && echo "$1 not found in ${nixpkgs_toplevel}/pkgs" && exit 1

    if [ "$numresults" -gt 1 ]; then
      results=$(echo "$results" | awk -F"${nixpkgs_toplevel}/pkgs/" '{print $2}')

      file=$(echo "$results" | fzf)

      full_path="${nixpkgs_toplevel}/pkgs/$file"

      nvim "$full_path"

    else
      result_path=$(echo "$results" | awk -F"${nixpkgs_toplevel}/pkgs/" '{print $2}')
      full_path="${nixpkgs_toplevel}/pkgs/$result_path"
      nvim "$full_path"
    fi
  '';
}
