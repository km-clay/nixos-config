{pkgs}:
pkgs.writeShellScriptBin "viconf" ''
  #!/usr/bin/env bash

  [ ! $# -eq 1 ] && echo "Usage: viconf <*.nix>" && exit 1

  results=$(find "$FLAKEPATH" -wholename "*$1*" -exec find {} \; | sort | uniq | rg '\.nix$')
  numresults=$(echo "$results" | wc -l)

  [ "$numresults" -eq 0 ] && echo "$1 not found in \$FLAKEPATH" && exit 1

  if [ "$numresults" -gt 1 ]; then
    # cut up the paths to give shorter path names to fuzzy finder
    results_prefix=$(echo "$results" | tail -n 1 | cut -d'/' -f-3)
    results=$(echo "$results" | cut -d'/' -f4-)
    results=$(echo "$results" | grep "$1")

    echo "$results" | tr ' ' '\n' | fzf | xargs -I {} nvim "$results_prefix"/{}
  else
    nvim "$results"
  fi
''
