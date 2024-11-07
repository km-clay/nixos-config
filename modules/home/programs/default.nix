{
  host,
  nur,
  nixvim,
  self,
  inputs,
  username,
  config,
  home-manager,
  ...
}:
{
  imports =
    [(import ./btop.nix)]
    ++ [(import ./yazi.nix)]
    ++ [(import ./kitty.nix)]
    ++ [(import ./fuzzel.nix)]
    ++ [(import ./eza.nix)]
    ++ [(import ./cava.nix)]
    ++ [(import ./bat.nix)]
    ++ [(import ./fzf.nix)]
    ++ [(import ./git.nix)]
    ++ [(import ./password-store.nix)]
    ++ [(import ./autojump.nix)]
    ++ [(import ./firefox.nix)]
    ++ [(import ./nixvim)];
}
