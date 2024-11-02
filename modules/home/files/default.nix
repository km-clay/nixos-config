{ ... }:

# This folder is for programs that do not have existing configuration modules in NixOS.
# Basically a to-do list for stuff I need to write my own modules for.
{
  imports = [ ./neofetch.nix ];
}
