{ pkgs }:

pkgs.writeShellApplication {
  name = "mkscreenshots";
  runtimeInputs = with pkgs; [ jq neofetch kitty coreutils nemo grimblast git ];
  text = ''
    if [ -n "$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "4")')" ]; then
      echo "There are windows in workspace 4. This script uses workspace 4, so move those windows and run it again."
      exit 1
    fi

    prev_workspace=$(hyprctl activeworkspace -j | jq '.id')

    hyprctl dispatch focusmonitor 0

    screenshotfetch() {
      neofetch

      kitty @ scroll-window 20-

      exec sleep infinity
    }

    closewindows() {
      hyprctl clients -j | jq -r '.[] | select(.workspace.name == "4") | .address' | while read -r addr; do
        hyprctl dispatch closewindow address:"$addr"
      done
    }

    temp_script=$(mktemp)
    screenshotfetch_var=$(declare -f screenshotfetch)
    echo "$screenshotfetch_var" > "$temp_script"
    echo "screenshotfetch" >> "$temp_script"
    chmod +x "$temp_script"

    hyprctl dispatch workspace 4
    hyprctl dispatch exec "[float;size 40% 25%;move 1% 66%] kitty bash -c '$temp_script'"
    hyprctl dispatch exec "[float;size 40% 50%;move 57% 8%] nemo"

    sleep 1
    grimblast save output "$FLAKEPATH"/assets/screens/desktop-neofetch.png

    closewindows

    hyprctl dispatch exec 'kitty nvim'
    hyprctl dispatch exec 'kitty yazi'
    hyprctl dispatch exec 'kitty'

    sleep 1
    grimblast save output "$FLAKEPATH"/assets/screens/desktop-busy.png

    (
    cd "$FLAKEPATH"
    latest_hash=$(git rev-parse HEAD)
    sed -i "s|\(https://github.com/pagedMov/nixos-config/commit/\)[a-f0-9]\{40\}|\1$latest_hash|" "$FLAKEPATH"/README.md
    )

    closewindows

    hyprctl dispatch workspace "$prev_workspace"
  '';
}
