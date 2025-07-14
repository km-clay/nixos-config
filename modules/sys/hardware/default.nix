{ inputs, nixpkgs, nixvim, config, self, username, host, ... }: {
  imports = [ (import ./bootloader.nix) ] ++ [ (import ./network.nix) ]
    ++ [ (import ./powerprofiles.nix) ]
    ++ [ (import ./kernel.nix) ];
}
