{
  pkgs,
}:

pkgs.writeShellScriptBin "viconf" ''
  #!/usr/bin/env bash

  [ ! $# -eq 1 ] && echo "Usage: viconf <*.nix>" && exit 1
  results=$(find "$FLAKEPATH" -name "*$1*" -exec find {} \; | sort | uniq | rg '\.nix$')
  numresults=$(echo "$results" | wc -l)
  [ "$numresults" -eq 0 ] && echo "$1 not found in \$FLAKEPATH" && exit 1
  if [ "$numresults" -gt 1 ]; then
    echo "$results" | tr ' ' '\n' | fzf | xargs -I {} nvim {}
  else
    nvim "$results"
  fi
''
