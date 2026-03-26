{ inputs, movLib }:

{
  inherit (import ./modules.nix { inherit inputs movLib; }) homeModules nixosModules;
  inherit (import ./shells.nix { inherit inputs; }) devShells;
  inherit (import ./packages.nix { inherit inputs; }) packages;
}
