{ pkgs }:
pkgs.writeShellApplication {
  name = "viconf";
  runtimeInputs = with pkgs; [ coreutils fd ripgrep fzf ];
  text = ''
    #!/usr/bin/env bash

    if [ ! $# -eq 1 ]; then
      results=$(find "$FLAKEPATH" -exec find {} \; | sort | uniq | rg '\.nix$')
      numresults=$(echo "$results" | wc -l)
    else
      results=$(find "$FLAKEPATH" -wholename "*$1*" -exec find {} \; | sort | uniq | rg '\.nix$')
      numresults=$(echo "$results" | wc -l)
    fi


    [ "$numresults" -eq 0 ] && echo "$1 not found in \$FLAKEPATH" && exit 1

    if [ "$numresults" -gt 1 ]; then
      # cut up the paths to give shorter path names to fuzzy finder
      results_prefix=$(echo "$results" | tail -n 1 | cut -d'/' -f-3)
      results=$(echo "$results" | cut -d'/' -f4-)
      results=$(echo "$results" | grep "$1")

      file=$(echo "$results" | tr ' ' '\n' | fzf)
      file="$results_prefix/$file"

      # Check if the file contains any non-UTF-8 characters
      if grep --color='auto' -P -q "[^\x00-\x7F]" "$file"; then
        NIXD_FLAGS="--semantic-tokens=false" nvim "$results_prefix"/"$file"
      else
        nvim "$file"
      fi

    else
      # Check if the file contains any non-UTF-8 characters
      if grep --color='auto' -P -q "[^\x00-\x7F]" "$results"; then
        NIXD_FLAGS="--semantic-tokens=false" nvim "$results"
      else
        nvim "$results"
      fi
    fi
  '';
}
