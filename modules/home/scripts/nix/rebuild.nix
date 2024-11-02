{
  host,
  self,
  pkgs,
}:
pkgs.writeShellScriptBin "rebuild" ''
   #!/run/current-system/sw/bin/bash

   scheck && runbg aplay ${self}/assets/sound/nixswitch-start.wav
   set -e
  nh os switch -H ${host} $HOME/.sysflake
   sudo nixos-rebuild switch --flake "$HOME/.sysflake#${host}"
   if [ $? -eq 0 ]; then
   	scheck && runbg aplay ${self}/assets/sound/update.wav
   else
   	scheck && runbg aplay ${self}/assets/sound/error.wav
   fi
''
