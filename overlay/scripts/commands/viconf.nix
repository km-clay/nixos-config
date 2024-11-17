{ pkgs }:
pkgs.writeShellApplication {
  name = "viconf";
  runtimeInputs = with pkgs; [ coreutils fd ripgrep fzf ];
  text = ''
    open_file() {
      file="$1"
      if grep -Pq "[^\x00-\x7F]" "$file"; then
        NIXD_FLAGS="--semantic-tokens=false" nvim "$file"
      else
        nvim "$file"
      fi
    }

    if [ $# -eq 1 ]; then
      results=$(find "$FLAKEPATH" -type f -name '*.nix' -path "*$1*")
    else
      results=$(find "$FLAKEPATH" -type f -name '*.nix')
    fi

    numresults=$(echo "$results" | grep -c '^')

    if [ "$numresults" -eq 0 ]; then
      echo "$1 not found in \$FLAKEPATH"
      exit 1
    elif [ "$numresults" -eq 1 ]; then
      file="$results"
      open_file "$file"
      exit 0
    fi

    # Handle multiple results
    results_prefix=$(echo "$results" | head -n 1 | cut -d'/' -f-4)
    results=$(echo "$results" | cut -d'/' -f5- | grep "$1")
    file=$(echo "$results" | fzf)

    if [ -n "$file" ]; then
      file="$results_prefix/$file"
      open_file "$file"
    else
      exit 1
    fi
  '';
}
