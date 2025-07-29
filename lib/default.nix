{ inputs, username, nixpkgsConfig ? { allowUnfree = true; } }:

rec {
  mkHost = import ./mk_host.nix;
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
