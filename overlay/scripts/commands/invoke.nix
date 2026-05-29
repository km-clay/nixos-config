{ pkgs }:
pkgs.writeShellApplication {
  name = "invoke";
  text = ''
    cmd="$1"
    shift
    playshellsound invoke.wav
    nix run nixpkgs#"$cmd" -- "$@"
  '';
}
