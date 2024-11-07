{
  host,
  self,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "rebuild";
  text = ''
    hooray() { scheck && runbg aplay ${self}/assets/sound/update.wav; }
    damn() { scheck && runbg aplay ${self}/assets/sound/error.wav; }
    [ $# -eq 0 ] && echo -e "\033[1;4;38;2;243;139;168mUsage\033[0m: rebuild -h for home config, rebuild -s for sys config" && damn && exit 1
    scheck && runbg aplay ${self}/assets/sound/nixswitch-start.wav
    case $1 in
      "-h" ) if nh home switch -c ${host}Home "$FLAKEPATH"; then hooray; else damn; fi;;
      "-s" ) if nh os switch -H ${host} "$FLAKEPATH"; then hooray; else damn; fi;;
      * ) echo -e "\033[1;4;38;2;243;139;168mUsage\033[0m: rebuild -h for home config, rebuild -s for sys config";;
    esac
  '';
}
