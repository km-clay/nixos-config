{ pkgs, }:
pkgs.writeShellApplication {
  name = "scheck";
  text = ''
    [ "$SOUNDS_ENABLED" = "true" ]
  '';
}
