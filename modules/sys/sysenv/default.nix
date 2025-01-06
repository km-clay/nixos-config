{ inputs, nixpkgs, nixvim, config, self, username, host, ... }: {
  imports = [ (import ./sddm.nix) ] ++ [ (import ./issue.nix) ]
  ++ [ (import ./nix.nix) ] ++ [ (import ./stylix.nix) ];
  #++ [ (import ./console.nix) ];
}
