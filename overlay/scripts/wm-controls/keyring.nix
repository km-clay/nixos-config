{ pkgs }:
pkgs.writeShellApplication {
  name = "keyring";
  runtimeInputs = with pkgs; [
    pass
    findutils
    ripgrep
    fzf
    wl-clipboard
    coreutils
  ];
  text = ''
    #!/run/current-system/sw/bin/bash

      # prevent multiple instances, conditional check happens in the hyprland bind
    touch /tmp/keyringfile
    trap "[ -f /tmp/keyringfile ] && /run/current-system/sw/bin/rm /tmp/keyringfile" EXIT SIGHUP SIGINT

      # get passwords from password store, remove .password store/ prefix and .gpg suffix, exlude .gpg-id file, open results in fzf
    pass_string=$(find "$HOME"/.password-store -type f | sed 's|.*/.password-store/||; s|\.gpg$||' | sed 's|^\([^/]*\)|\x1b[32m\1\x1b[0m|' | rg -v "\.git|.gpg-id" | sort -r | fzf --border --border-label="$(whoami)'s keyring" --ansi --layout=reverse)

    # prevents cliphist from writing passwords to the clipboard history
    pkill -STOP wl-paste

    # copy password
    pass -c "$pass_string" > /dev/null
    echo "Password copied. Clearing clipboard in 10 seconds."

    # start a timer for 10 seconds, clear clipboard, resume cliphist tracking
    nohup bash <<-EOF > /dev/null &
      sleep 10
      wl-copy -c
      pkill -CONT wl-paste
    EOF

    /run/current-system/sw/bin/rm /tmp/keyringfile
    sleep 0.5
    exit 0
  '';
}
