{ pkgs }:
pkgs.writeShellApplication {
  name = "git-compose";
  runtimeInputs = with pkgs; [
    git
    gawk
    myScripts.color-commit
  ];
  text = ''
    set -e

    toplevel=$(git rev-parse --show-toplevel 2>/dev/null)

    if [ -z "$toplevel" ]; then
      echo "You aren't in a git repository."
      exit 1
    fi

    (
      cd "$toplevel" || { echo "Failed to change to repo root"; exit 1; }

      unstaged=$(git status --porcelain | awk '{print $2}') || { echo "Failed to get git status"; exit 1; }

      if [ -z "$unstaged" ]; then
        echo "No unstaged files found."
        exit 0
      fi

      git reset > /dev/null 2>&1

      tmpfile=$(mktemp) || { echo "Failed to create a temporary file"; exit 1; }
      trap 'rm -f "$tmpfile"' EXIT

      filecontent=$(
        echo "# Compose your commits here"
        echo "# To cancel this operation, exit without saving (e.g., :q!)"
        echo "#"
        echo "# Format should be as follows:"
        echo "# <some_commit_message>"
        echo "# <file1>"
        echo "# <file2>"
        echo "# <file3>"
        echo "#"
        echo "# Groups are separated by empty lines"
        echo "# Commits will be created for each group of files"
        echo "# using the given commit message at the top of the group"
        echo
        echo "$unstaged"
      )
      echo "$filecontent" > "$tmpfile"

      nvim -c 'setfiletype gitcommit' "$tmpfile"

      if [ "$(cat "$tmpfile")" = "$filecontent" ]; then
        echo "No changes found; cancelling composition."
        exit 1
      fi

      collecting=false
      msg=""
      lines=()

      while IFS= read -r line; do
        [[ "$line" =~ ^#[[:space:]]* ]] && continue
        if [ -z "$line" ]; then
          if [ -n "$msg" ] && [ ''${#lines[@]} -gt 0 ]; then
            git add "''${lines[@]}"
            git commit -m "$msg" | color-commit
          fi
          collecting=false
          msg=""
          lines=()
        elif [ "$collecting" = "false" ]; then
          collecting=true
          msg="$line"
        else
          lines+=("./$line")
        fi
      done < "$tmpfile"

      # Final cleanup
      if [ -n "$msg" ] && [ ''${#lines[@]} -gt 0 ]; then
        git add "''${lines[@]}"
        git commit -m "$msg" | color-commit
      fi
    )
  '';
}
