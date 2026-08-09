{ writeShedBin }:
writeShedBin "ptt-status" ''
  : "''${XDG_RUNTIME_DIR:?runtime dir not set}"

  status=$(thru "$XDG_RUNTIME_DIR/ptt.state")

  status_json() {
    printf '{"text": "%s", "tooltip": "push-to-talk", "class": "%s"}' "$1" "$2"
  }

  case "$status" in
    muted)
      status_json "$(printf '\uf131')" "muted"
    ;;
    unmuted)
      status_json "$(printf '\uf130')" "unmuted"
    ;;
    *)
      exit 1
    ;;
  esac
''
