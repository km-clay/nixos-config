{
  inputs,
  nixpkgs,
  nixvim,
  config,
  self,
  username,
  host,
  ...
}: {
  imports =
    [(import ./sddm.nix)]
    ++ [(import ./issue.nix)]
    ++ [(import ./stylix.nix)];
}
