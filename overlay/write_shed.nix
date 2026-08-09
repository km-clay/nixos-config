pkgs: name: argsOrScript:
let
  lib = pkgs.lib;
  interpreter = "${lib.getExe' pkgs.shed "shed"}";
  check = "${lib.getExe' pkgs.buildPackages.shed "shed"} -n";
in
  if lib.isAttrs argsOrScript && !lib.isDerivation argsOrScript then
    pkgs.writers.makeScriptWriter (argsOrScript // { inherit interpreter check; }) name
  else
    pkgs.writers.makeScriptWriter { inherit interpreter check; } name argsOrScript
