{
  host,
  self,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "rebuild";
  text = ''
    [ $# -eq 0 ] && echo "Usage: rebuild -h for home config, rebuild -s for sys config"
    scheck && runbg aplay ${self}/assets/sound/nixswitch-start.wav
    set -e
    hooray() { scheck && runbg aplay ${self}/assets/sound/update.wav }
    damn() { scheck && runbg aplay ${self}/assets/sound/error.wav }
    case $1 in
      "-h" ) if nh home switch -c ${host}Home "$FLAKEPATH"; then hooray; else damn; fi;;
      "-s" ) if nh os switch -H ${host} "$FLAKEPATH"; then hooray; else damn; fi;;
      * ) echo "Usage: rebuild -h for home config, rebuild -s for sys config";;
    esac
  '';
}
