{ host, self, pkgs, }:
pkgs.writeShellApplication {
  name = "rebuild";
  text = ''
    checkbools() { [ "$all" = false ] && [ "$system" = false ] && [ "$home" = false ]; }
    checkflags() {
      str="$1"
      [ -z "$str" ] && return
      char="''${str: -1}"
      str="''${str::-1}"
      if [ "$char" = "-" ]; then return 0; fi
      case "$char" in
        "a") if checkbools; then echo "$usage" && exit 1; else all=true; fi ;;
        "s") if checkbools; then system=true; else echo "$usage" && exit 1; fi ;;
        "h") if checkbools; then home=true; else echo "$usage" && exit 1; fi ;;
        "n") if [ "$dry" = false ]; then dry=true; else echo "$usage" && exit 1; fi ;;
        *) echo -e "$usage" && exit 1 ;;
      esac
      checkflags "$str"
    }

    system=false
    home=false
    all=false
    dry=false

    hooray() { scheck && runbg aplay "${self}/assets/sound/update.wav"; }
    damn() { scheck && runbg aplay "${self}/assets/sound/error.wav"; }

    usage="\033[1;4;38;2;243;139;168mUsage\033[0m: rebuild -h for home config, rebuild -s for sys config, rebuild -a for both. Including 'n' with the flag does a dry run, i.e. rebuild -nh"

    { [ $# -eq 0 ] || [ $# -gt 1 ]; } && echo -e "$usage" && damn && exit 1
    if [[ "$1" =~ ^-[a-zA-Z]+$ ]]; then
      checkflags "$1"
    else
      echo -e "$usage" && damn && exit 1
    fi

    dry_flag=""
    [ "$dry" = true ] && dry_flag="-n"

    [ "$all" = true ] && if sudo sleep 0.1 && nh os switch $dry_flag -H "${host}" "$FLAKEPATH" && nh home switch $dry_flag -c "${host}Home" "$FLAKEPATH"; then hooray; else damn; fi
    [ "$system" = true ] && if nh os switch $dry_flag -H "${host}" "$FLAKEPATH"; then hooray; else damn; fi
    [ "$home" = true ] && if nh home switch $dry_flag -c "${host}Home" "$FLAKEPATH"; then hooray; else damn; fi
  '';
}
