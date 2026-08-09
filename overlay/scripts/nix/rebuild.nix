{
  host,
  self,
  pkgs,
}:
let
  playshellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  nh = "${pkgs.nh}/bin/nh";
in
pkgs.writeShellApplication {
  name = "rebuild";
  text = ''
    exec > /dev/tty 2>&1
    set +e

    usage="\033[1;4;38;2;243;139;168mUsage\033[0m: rebuild -h for home config, rebuild -s for sys config, rebuild -a for both. Including 'n' with the flag does a dry run, i.e. rebuild -nh"

    hooray() { ${playshellsound} "update.wav"; }
    damn() { ${playshellsound} "error.wav"; }
    update_done() { ${playshellsound} "update_alt.wav"; }

    system=0
    home=0
    all=0
    dry=0
    update=0
    started=0
    result=0

    while getopts ":ashUn" opt; do
      case "$opt" in
        a) all=1;;
        s) system=1;;
        h) home=1;;
        U) update=1;;
        n) dry=1;;
        *) echo -e "$usage"; damn; exit 1;;
      esac
    done

    shift $((OPTIND - 1))

    if (( $# != 0 )); then
      echo -e "$usage"
      damn
      exit 1
    fi

    if ((all + system + home != 1)); then
      echo -e "$usage"; damn; exit 1
    fi

    dry_flag=""

    start() {
      if ((started == 1)); then return 0; fi

      ${playshellsound} "nixswitch-start.wav"
      started=1
    }
    update_flake() {
      start;
      (cd "$FLAKEPATH" && nix flake update)
      result=$?
      (( result == 0 )) && update_done
      return $result
    }
    rebuild_sys() {
      start;
      ${nh} os switch $dry_flag -H "${host}" "$FLAKEPATH"
      result=$?
      return $result
    }

    rebuild_home() {
      start;
      ${nh} home switch $dry_flag -c "${host}Home" "$FLAKEPATH"
      result=$?
      return $result
    }

    rebuild_all() {
      rebuild_sys
      (( result != 0 )) && return $result
      rebuild_home
      return $result
    }

    (( dry    != 1 )) && (cd "$FLAKEPATH" && git add .)

    (( dry    == 1 )) && dry_flag="-n"
    (( update == 1 )) && sudo sleep 0.1 && update_flake

    if (( result == 0 )); then
      (( all    == 1 )) && sudo sleep 0.1 && rebuild_all
      (( system == 1 )) && rebuild_sys
      (( home   == 1 )) && rebuild_home
    fi

    if (( result != 0 )); then
      damn
    else
      hooray
    fi

    exit $result
  '';
}
