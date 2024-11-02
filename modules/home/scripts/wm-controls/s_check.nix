{
  self,
  pkgs,
}:
pkgs.writeShellScriptBin "scheck" ''
  #!/run/current-system/sw/bin/bash

  [ "$SOUNDS_ENABLED" -eq 1 ]
''
