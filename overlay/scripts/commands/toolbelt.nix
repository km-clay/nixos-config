{ pkgs }:
pkgs.writeShellApplication {
  name = "toolbelt";
  runtimeInputs = with pkgs; [
    cliphist
    fzf
    ripgrep
    gawk
    wl-clipboard
    hyprland
    alsa-utils
    btop
    coreutils
  ];
  text = ''
    cliphistory() {
      selection=$(cliphist list | fzf --preview="
        index=\$(echo {} | awk '{print \$1}'); \
        mime=\$(cliphist decode \$index | file -i -); \
        if echo \"\$mime\" | grep -q 'image'; then \
            echo \$(cliphist list | rg \"^\$index\" | cut -d ' ' -f 2- | fmt -w 30); \
        else \
            cliphist decode \"\$index\" | fmt -w 30; \
        fi" --prompt="> " | awk '{print $1}')
      [ -z "$selection" ] && return 1
      cliphist decode "$selection" | wl-copy
    }
    btop_cmd() {
      hostname="$(cat /etc/hostname)"
      if [ "$hostname" = "oganesson" ] || [ "$hostname"  = "phosphorous" ]; then
        hyprctl dispatch resizeactive 20% 155% &&
        moveonscreen --center &&
        btop &&
        hyprctl dispatch resizeactive exact 40% 25% &&
        moveonscreen
      else
        hyprctl dispatch resizeactive exact 60% 68% &&
        moveonscreen --center &&
        btop &&
        hyprctl dispatch resizeactive exact 40% 25% &&
        moveonscreen
      fi
    }

    running=true

    declare -A commands=(
        ["Change Wallpaper"]="hyprctl dispatch resizeactive 20% 50% && moveonscreen --center && if chpaper; then running=false; else moveonscreen; fi"
        ["Change System Color Scheme"]="hyprctl dispatch resizeactive 10% 80% && moveonscreen --center && if chscheme; then running=false; else hyprctl dispatch resizeactive exact 40% 25% && moveonscreen; fi"
        ["Open System Monitor"]="btop_cmd"
        ["Open Volume Controls"]="hyprctl dispatch resizeactive 10% 80% && moveonscreen --center && alsamixer && hyprctl dispatch resizeactive exact 40% 25% && moveonscreen"
        ["Open Keyring"]="hyprctl dispatch resizeactive -300 0 && moveonscreen && if keyring; then running=false; else hyprctl dispatch resizeactive exact 40% 25% && moveonscreen; fi"
        ["View Clipboard History"]="hyprctl dispatch resizeactive 45% 120% && moveonscreen --center && if cliphistory;then running=false; else hyprctl dispatch resizeactive exact 40% 25% && moveonscreen; fi"
    )

    ordered_commands=(
        "Open Keyring"
        "Open System Monitor"
        "Open Volume Controls"
        "Change Wallpaper"
        "Change System Color Scheme"
        "View Clipboard History"
    )

    # Use fzf to select a command with preview
    while $running; do
    selected_command=$(printf "%s\n" "''${ordered_commands[@]}" | fzf --prompt="> ")


     #Execute the selected command if selection is not empty
      if [[ -n $selected_command ]]; then
        eval "''${commands[$selected_command]}"
      else
        running=false
      fi
    done
  '';
}
