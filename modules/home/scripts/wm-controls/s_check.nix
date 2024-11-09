{ pkgs, }:
pkgs.writeShellApplication {
  name = "scheck";
  text = ''
    #!/run/current-system/sw/bin/bash

    [ "$SOUNDS_ENABLED" -eq 1 ]
  '';
}
