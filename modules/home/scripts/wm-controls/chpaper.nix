{pkgs}:
pkgs.writeShellScriptBin "chpaper" ''
  paper="$\{self}/assets/wallpapers/$(find "$FLAKEPATH"/assets/wallpapers -exec basename {} \; | rg "\.\w+$" | fzf --preview "chafa -s 30x40 $FLAKEPATH/assets/wallpapers/{}")"
  [ "$paper" = "$\{self}/assets/wallpapers/" ] && echo "Cancelling wallpaper change" && exit 1
  echo "$paper" | xargs -I {} sed -i '/wallpaper =/s|"[^"]*"|"{}"|' "$FLAKEPATH"/modules/sys/environment/stylix.nix
  echo "Successfully changed wallpaper. Rebuild now?" && \
  select choice in "Yes" "No"; do
  	case $choice in
  		"Yes")
  			rebuild;pkill -9 hyprpaper;exit 0;;
  		"No")
  			echo "Exiting...";exit 0;;
  	esac
  done
''
