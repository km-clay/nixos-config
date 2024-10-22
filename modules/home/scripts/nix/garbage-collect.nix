{
  self,
  pkgs,
}:
pkgs.writeShellScriptBin "garbage-collect" ''
  #!/run/current-system/sw/bin/bash


  echo "This will delete all unused paths in the nix store and delete any files in the gtrash folder."
  echo -e "\033[1;4;38;2;243;139;168mThis process is irreversible.\033[0m Are you sure?"
  select yn in "Yes" "No"; do
  	case $yn in
  		Yes )  echo "Sweeping system...";scheck && runbg aplay "$HOME/assets/sound/sys/collectgarbage.wav";break;;
  		No ) echo "Canceling garbage collection."; return;;
  	esac
  done
  output=$(nix-collect-garbage | tee /dev/tty)

  nix_freed=$(echo "$output" | grep -oP '\d+(\.\d+)? MiB freed' | cut -d' ' -f1)

  if [ "$(ls -A ~/.local/share/Trash/files/ 2>/dev/null)" ]; then
      rm_freed=$(du ~/.local/share/Trash/files 2> /dev/null | awk '{print $1}')
  	rm_freed=$(echo "scale=2; $rm_freed / 1000" | bc)
  	/run/current-system/sw/bin/rm -rfv ~/.local/share/Trash/files
  	mkdir ~/.local/share/Trash/files
  else
  	rm_freed="0"
  fi
  total_freed=$(echo "$nix_freed + $rm_freed" | bc)
  echo -e "System cleaning complete, freed \033[1;4;38;2;166;227;161m$total_freed MiB\033[0m in total"
  scheck && runbg aplay "$HOME/assets/sound/sys/rm.wav"
''
