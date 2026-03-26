{ pkgs, ... }@args:
{
  imports = [
    (import ./hardware args)
    (import ./software args)
    (import ./sysenv args)
  ];
}
