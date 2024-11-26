{ pkgs }:
pkgs.writeShellApplication {
  name = "garbage-collect";
  runtimeInputs = with pkgs; [
    bash
    coreutils
    gnugrep
    bc
    alsa-utils
    findutils
    nix
  ];
  text = ''
    convert_size() {
      units=("MB" "GB" "TB" "PB")
      size=$1
      divisions=0
      while [ "$(echo "$size >= 1024.0" | bc -l)" -eq 1 ]; do
          size=$(echo "scale=2; $size / 1024" | bc -l)
          divisions=$((divisions + 1))
      done
      echo -e "\033[1;4;38;2;166;227;161m$size ''${units[divisions]}\033[0m"
    }

    echo "This will delete all unused paths in the nix store and delete any files in the gtrash folder."
    echo -e "\033[1;4;38;2;243;139;168mThis process is irreversible.\033[0m Are you sure?"
    select yn in "Yes" "No"; do
      case $yn in
        Yes )  echo "Sweeping system..."; scheck && runbg aplay "$HOME/assets/sound/sys/collectgarbage.wav"; break;;
        No ) echo "Canceling garbage collection."; return;;
      esac
    done

    output=$(nix-collect-garbage | tee /dev/tty)
    nix_freed=$(echo "$output" | grep -oP '\d+(\.\d+)? MiB freed' | cut -d' ' -f1)

    echo "Done, nix-collect-garbage freed up $(convert_size "$nix_freed")"

    # Get the size of the trash folder before deleting
    if [ "$(find ~/.local/share/Trash/files/ 2>/dev/null)" ]; then
      echo "Deleting trash files..."
      echo "Found $(find ~/.local/share/Trash/files/ | wc -l) files in trash can."
      rm_freed=$(du -sm ~/.local/share/Trash/files | awk '{print $1}')
      sudo /run/current-system/sw/bin/rm -rf ~/.local/share/Trash/files
      mkdir -p ~/.local/share/Trash/files
      echo "Done, deleting trash freed up $(convert_size "$rm_freed")"
    else
      rm_freed="0"
    fi

    total_freed=$(echo "$nix_freed + $rm_freed" | bc)
    total_converted=$(convert_size "$total_freed")

    echo "Optimizing nix store..."
    nix store optimise

    echo -e "System cleaning complete, freed \033[1;4;38;2;166;227;161m$total_converted\033[0m in total"


    scheck && runbg aplay "$HOME/assets/sound/sys/rm.wav"
  '';
}
