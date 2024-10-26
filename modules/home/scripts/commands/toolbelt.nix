{ pkgs, ... }:

pkgs.writeShellScriptBin "toolbelt" ''
calc() {
	echo "Give me some math"
	read input

	answer=$(echo "$input" | bc)

	if [ "$input" = "9+10" ] \
		|| [ "$input" = "9 +10" ] \
		|| [ "$input" = "9+ 10" ] \
		|| [ "$input" = "9 + 10" ]; then
		answer="21"
	fi
	echo "$input = $answer"
	echo "$answer" | wl-copy
	echo "answer copied to clipboard. press any key to exit."
	read -n 1 -s
}

chpaper() {
	paper="$\{self}/assets/wallpapers/$(find "$FLAKEPATH"/assets/wallpapers -exec basename {} \; | rg "\.\w+$" | fzf --preview "chafa -s 30x40 $FLAKEPATH/assets/wallpapers/{}")"
	[ "$paper" = "$\{self}/assets/wallpapers/" ] && echo "Cancelling wallpaper change" && exit 0
	echo "$paper" | xargs -I {} sed -i '/wallpaper =/s|"[^"]*"|"{}"|' "$FLAKEPATH"/flake.nix
	echo "Successfully changed wallpaper. Rebuild now?" && \
	select choice in "Yes" "No"; do
		case $choice in
			"Yes")
				rebuild;pkill -9 hyprpaper;exit 0;;
			"No")
				echo "Exiting...";exit 0;;
		esac
	done
}

declare -A commands=(
    ["Change Wallpaper"]="chpaper"
    ["Change System Color Scheme"]="exec hyprctl dispatch exec '[float;size 50% 70%;move onscreen cursor -50% -50%] kitty chscheme'"
    ["Open System Monitor"]="exec hyprctl dispatch exec '[float;size 50% 70%;move onscreen cursor -50% -50%] kitty btop'"
    ["Open Volume Controls"]="exec hyprctl dispatch exec '[float;size 50% 70%;move onscreen cursor -50% -50%] pavucontrol'"
    ["Open Keyring"]="exec hyprctl dispatch exec '[float;size 25% 30%;move onscreen cursor 20 20] [ ! -f /tmp/keyringfile ] && kitty keyring'"
    ["Calculator"]="calc"
)

declare -A descriptions=(
    ["Change Wallpaper"]="Choose a wallpaper to switch to from \$FLAKEPATH/assets/wallpapers. Requires rebuilding the system and restarting hyprpaper."
    ["Change System Color Scheme"]="Changes the base16 color scheme used by stylix to color system applications."
    ["Open System Monitor"]="Opens a btop window."
    ["Open Volume Controls"]="Opens pavucontrol."
    ["Open Keyring"]="Opens a fuzzy finder with all of the paths held in ~/.password-store. Selecting one uses pass to copy that password to the clipboard. Password is cleared from clipboard history after 45 seconds."
    ["Calculator"]="Wrapper for bc. Output is copied to the clipboard."
)

# Export the descriptions array so it's available to the subshell
export -A descriptions

# Use fzf to select a command with preview
selected_command=$(printf "%s\n" "''${!commands[@]}" | fzf --preview="
cleaned_key=\$(echo {} | tr -d \"'\"); \
echo \"Cleaned key: \$cleaned_key\"; \
declare -A descriptions=(
    [\"Change Wallpaper\"]=\"Choose a wallpaper to switch to from the assets/wallpapers folder in the system flake directory. Requires rebuilding the system and restarting hyprpaper.\"
    [\"Change System Color Scheme\"]=\"Changes the base16 color scheme used by stylix to color system applications.\"
    [\"Open System Monitor\"]=\"Opens a btop window.\"
    [\"Open Volume Controls\"]=\"Opens pavucontrol.\"
    [\"Open Keyring\"]=\"Opens a fuzzy finder with all of the paths held in ~/.password-store. Selecting one uses pass to copy that password to the clipboard. Password is cleared from clipboard history after 45 seconds.\"
    [\"Calculator\"]=\"Wrapper for bc. Output is copied to the clipboard.\"
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
fi
''
