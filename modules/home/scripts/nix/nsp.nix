{
  pkgs
}:
pkgs.writeShellApplication {
  name = "nsp";
  text = ''
    #!/run/current-system/sw/bin/bash

    nix-shell -p "$@" --run zsh
  '';
}
