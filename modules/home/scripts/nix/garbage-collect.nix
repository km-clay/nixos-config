{
  pkgs
}:
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
    #!/run/current-system/sw/bin/bash

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

    # Get the size of the trash folder before deleting
    if [ "$(ls -A ~/.local/share/Trash/files/ 2>/dev/null)" ]; then
      rm_freed=$(du -sm ~/.local/share/Trash/files | awk '{print $1}')
      /run/current-system/sw/bin/rm -rfv ~/.local/share/Trash/files/*  # Verbose output
      mkdir -p ~/.local/share/Trash/files
    else
      rm_freed="0"
    fi

    total_freed=$(echo "$nix_freed + $rm_freed" | bc)

    units=("MB" "GB" "TB" "PB")
    divisions=0
    while [ "$(echo "$total_freed >= 1024.0" | bc -l)" -eq 1 ]; do
        total_freed=$(echo "scale=2; $total_freed / 1024" | bc -l)
        divisions=$((divisions + 1))
    done

    echo -e "System cleaning complete, freed \033[1;4;38;2;166;227;161m$total_freed ''${units[$divisions]}\033[0m in total"

    scheck && runbg aplay "$HOME/assets/sound/sys/rm.wav"
  '';
}
