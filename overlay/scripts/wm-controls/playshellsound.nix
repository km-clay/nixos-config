{ pkgs }:

pkgs.writeShellApplication {
  name = "playshellsound";
  runtimeInputs = with pkgs; [
    alsa-utils
    pkgs.myScripts.runbg
  ];
  text = ''
    if [ $# -ne 1 ]; then
      echo "Usage: playshellsound <path/to/sound>"
      exit 1
    fi
    if scheck; then
      runbg aplay "$1"
    else
      exit 1
    fi
  '';
}
