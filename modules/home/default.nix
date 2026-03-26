{ pkgs, movLib, username, self, ... }@args:
{
  imports = [
    (import ./programs args)
    (import ./environment args)
    (import ./files.nix args)
    ./profiles/options.nix
    ./profiles/cli.nix
    ./profiles/graphical.nix
  ];
}
