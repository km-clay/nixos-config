{
  self,
  pkgs,
}:
pkgs.writeShellScriptBin "nsp" ''
  #!/run/current-system/sw/bin/bash

  nix-shell -p "$@" --run zsh
''
