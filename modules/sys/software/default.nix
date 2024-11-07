{
  inputs,
  nixpkgs,
  config,
  self,
  username,
  host,
  ...
}: {
  imports =
    [(import ./packages.nix)]
    ++ [(import ./programs.nix)]
    ++ [(import ./services.nix)]
    ++ [(import ./virtualization.nix)]
    ++ [(import ./gaming)];
}
