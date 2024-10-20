{
  pkgs,
}:
pkgs.writeShellScriptBin "chscheme" (builtins.readFile ./chscheme.sh)

