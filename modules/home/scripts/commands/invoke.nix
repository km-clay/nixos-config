{
  pkgs
}:
pkgs.writeShellApplication {
  name = "invoke";
  text = ''
    cmd="$1"
    shift
    nix run nixpkgs#"$cmd" -- "$@"
  '';
}
