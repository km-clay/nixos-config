{
  self,
  pkgs,
}:
pkgs.writeShellScriptBin "invoke" ''
  cmd="$1"
  shift
  nix run nixpkgs#"$cmd" -- "$@"
''
