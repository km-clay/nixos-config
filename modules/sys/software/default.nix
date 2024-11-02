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
    ++ [(import ./nixvim)]
    ++ [(import ./module-test.nix)]
    ++ [(import ./virtualization.nix)]
    ++ [(import ./gaming)];
}
