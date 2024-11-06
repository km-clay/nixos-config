{
  host,
  self,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "rebuild";
  text = ''
    scheck && runbg aplay ${self}/assets/sound/nixswitch-start.wav
    set -e
    nh os switch -H ${host} "$HOME"/.sysflake
    if sudo nixos-rebuild switch --flake "$HOME/.sysflake#${host}"; then
      scheck && runbg aplay ${self}/assets/sound/update.wav
    else
      scheck && runbg aplay ${self}/assets/sound/error.wav
    fi
  '';
}
