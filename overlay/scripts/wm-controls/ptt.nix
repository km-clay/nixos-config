{ writeShedBin }:
writeShedBin "ptt-daemon" ''
  : "''${XDG_RUNTIME_DIR:?runtime dir not set}"
  LOCK="$XDG_RUNTIME_DIR/ptt.lock"
  SOCK="$XDG_RUNTIME_DIR/ptt.sock"
  STATE_FILE="$XDG_RUNTIME_DIR/ptt.state"

  # 0 = push-to-talk
  # 1 = push-to-mute
  declare -i MODE=1

  if [ -n "$1" ]; then
    case "$1" in
      key_down|key_up|toggle_mode)
        sock -U "$SOCK" 3 || { echo "ptt daemon not running" >&2; exit 1; }
        printf '%s\n' "$1" >&3
        exec 3>&-
        exit 0
      ;;
      *)
        echo "invalid request"
        exit 1
      ;;
    esac
  fi

  # time in seconds to keep holding after hotkey release
  HANGOVER="0.150"
  # PID of current hangover
  HANGOVER_PID=""

  cancel_hangover() {
    if [ -n "$HANGOVER_PID" ]; then
      kill "$HANGOVER_PID" 2>/dev/null
      HANGOVER_PID=""
    fi
  }

  mute() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1;
    echo "muted" > "$STATE_FILE"
    pkill -RTMIN+8 waybar
  }
  unmute() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0;
    echo "unmuted" > "$STATE_FILE"
    pkill -RTMIN+8 waybar
  }

  resting() { if (( MODE == 0 )); then mute; else unmute; fi; }
  active() { if (( MODE == 0 )); then unmute; else mute; fi; }

  on_press() {
    cancel_hangover
    active
  }

  on_release() {
    cancel_hangover
    { sleep "$HANGOVER"; resting; } &
    HANGOVER_PID=$!
  }

  serve_one() {
    accept "$1" -v conn || return
    defer exec "$conn">&-

    while IFS= read -r cmd; do
      case "$cmd" in
        toggle_mode)
          MODE=$(( (MODE + 1) % 2 ))
          cancel_hangover
          resting
        ;;
        key_*)
          case "''${cmd#key_}" in
            up)
              on_release
            ;;
            down)
              on_press
            ;;
          esac
        ;;
      esac
    done <&"$conn"
  }

  exec 9>"$XDG_RUNTIME_DIR/ptt.lock"
  flock -n 9 || { echo "ptt daemon already running" >&2; exit 1; }

  resting

  listen -U "$SOCK" -v lfd
  defer rm -f "$SOCK"

  while true; do serve_one "$lfd"; done
''
