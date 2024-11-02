{
  self,
  pkgs,
}:
pkgs.writeShellScriptBin "splash" ''
   #!/bin/bash

   echo "NixOS kernel ver. $(uname -a | awk '{print $3}') x86_64 GNU/Linux"
   date +"%A %B %-d %Y"
  echo
  echo " NixOS" | toilet -f 3d | lolcat -S 25
   echo
''
