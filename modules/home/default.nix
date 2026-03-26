{ pkgs, movLib, username, self, ... }@args:
{
  imports = [
    (import ./programs args)
    (import ./environment args)
    (import ./files.nix args)
    (import ./profiles/options.nix args)
    (import ./profiles/cli.nix args)
    (import ./profiles/graphical.nix args)
  ];
}
