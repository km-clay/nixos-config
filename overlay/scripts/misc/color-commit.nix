{ pkgs }:

pkgs.writeShellApplication {
  name = "color-commit";
  text = ''
    stdin=$(cat)
    [ -z "$stdin" ] && echo "Requires input via stdin" && exit 1

    teal="\\\033[38;2;180;249;248m"
    pink="\\\033[38;2;187;154;247m"
    reset="\\\033[0m"
    green_bg="\\\033[48;2;16;55;39m"
    red_bg="\\\033[48;2;62;21;31m"
    blue_bg="\\\033[48;2;33;73;129m"

    branch=$(git branch | grep "\*" | cut -d' ' -f2)

    output=$(echo "$stdin" | grep -A 1 -E "\[''${branch} ")
    [ -z "$output" ] && echo "This doesn't look like commit output: " && echo "$stdin" && exit 1

    echo "$output" | while IFS= read -r line; do
      [ "$line" = "--" ] && continue

      if [[ "$line" =~ ^\[$branch ]]; then
        line=$(echo "$line" | sed -E "s/\[([a-zA-Z0-9_-]+) ([a-zA-Z0-9]{7})\] (.*)/$(printf '%s' "$teal")\[\\1 \\2\]$(printf '%s' "$pink") \"\3\"$(printf '%s' "$reset")/")
        echo -e "$line"
      else
        line=$(echo "$line" | sed -E \
          -e "s/([0-9]+ file(s)? changed,?)/''${blue_bg}\1''${reset}/g" \
          -e "s/([0-9]+ insertion(s)?\(\+\),?)/''${green_bg}\1''${reset}/g" \
          -e "s/([0-9]+ deletion(s)?\(-\),?)/''${red_bg}\1''${reset}/g")
        echo -e "$line"
        echo
      fi
    done
  '';
}
