{ inputs, username, nixpkgsConfig ? { allowUnfree = true; } }:

let
  mkHost = import ./mk_host.nix;
in
{
  inherit mkHost;
  foldHosts = hosts: inputs.nixpkgs.lib.foldl'
    (acc: host:
      let result = mkHost ({ inherit inputs username nixpkgsConfig; } // host);
      in {
        nixosConfigurations = acc.nixosConfigurations // result.nixosConfigurations;
        homeConfigurations = acc.homeConfigurations // result.homeConfigurations;
      })
    { nixosConfigurations = {}; homeConfigurations = {}; }
    hosts;
}
