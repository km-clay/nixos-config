{ pkgs, ... }:

pkgs.writeShellScriptBin "toolbelt" ''
hostname=$(cat /etc/hostname)

cliphistory() {
  selection=$(cliphist list | fzf --preview="
    index=\$(echo {} | awk '{print \$1}'); \
    mime=\$(cliphist decode \$index | file -i -); \
    if echo \"\$mime\" | grep -q 'image'; then \
        echo \$(cliphist list | rg \"^\$index\" | cut -d ' ' -f 2- | fmt -w 30); \
    else \
        cliphist decode \"\$index\" | fmt -w 30; \
    fi" --prompt="> " | awk '{print $1}')
  cliphist decode "$selection" | wl-copy
}
btop_cmd() {
  if [ "$hostname" = 'oganesson' ]; then
    hyprctl dispatch resizeactive 20% 140% &&
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
    ["Change Wallpaper"]="moveonscreen --center && if chpaper; then running=false; else moveonscreen; fi"
    ["Change System Color Scheme"]="hyprctl dispatch resizeactive 10% 80% && moveonscreen --center && if chscheme; then running=false; else hyprctl dispatch resizeactive exact 40% 25% && moveonscreen; fi"
    ["Open System Monitor"]="hyprctl dispatch resizeactive 20% 140% && moveonscreen --center && btop_cmd && hyprctl dispatch resizeactive exact 40% 25% && moveonscreen"
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
selected_command=$(printf "%s\n" "''${ordered_commands[@]}" | fzf --preview="
cleaned_key=\$(echo {} | tr -d \"'\"); \
echo \"Cleaned key: \$cleaned_key\"; \
declare -A descriptions=(
    [\"Change Wallpaper\"]=\"Choose a wallpaper to switch to from the assets/wallpapers folder in the system flake directory. Requires rebuilding the system and restarting hyprpaper.\"
    [\"Change System Color Scheme\"]=\"Changes the base16 color scheme used by stylix to color system applications.\"
    [\"Open System Monitor\"]=\"Opens a btop window.\"
    [\"Open Volume Controls\"]=\"Opens alsamixer.\"
    [\"Open Keyring\"]=\"Opens a fuzzy finder with all of the paths held in ~/.password-store. Selecting one uses pass to copy that password to the clipboard. Password is cleared from clipboard history after 45 seconds.\"
    [\"View Clipboard History\"]=\"Opens clipboard history. Selecting an item copies it to the clipboard.\"
); \
if [[ -v descriptions[\$cleaned_key] ]]; then \
		clear; \
    echo \''${descriptions[\$cleaned_key]} | fmt -w 28; \
else \
		clear; \
    echo \"No description available\"; \
fi" --prompt="> ")


 #Execute the selected command if selection is not empty
	if [[ -n $selected_command ]]; then
		eval "''${commands[$selected_command]}"
	else
		running=false
	fi
done
''
