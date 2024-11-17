{ pkgs, self }:
pkgs.writeShellApplication {
  name = "invoke";
  text = ''
    cmd="$1"
    shift
    playshellsound ${self}/assets/sound/invoke.wav
    nix run nixpkgs#"$cmd" -- "$@"
  '';
}
