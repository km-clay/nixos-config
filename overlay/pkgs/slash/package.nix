{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
				pname = "slash";
				version = "v0.5.0_662cb43";

				  src = pkgs.fetchFromGitHub {
    owner = "pagedMov";
    repo = "slash";
    rev = "662cb43e499d179579d99bf358073516605230ea";
    hash = "sha256-4DKAhRkd1XeDNyYH8yL1TnbTc6hZnp2+UV7UYeDRkpE=";
  };
  

				doCheck = false; # TODO: Find a way to make tests work

				cargoLock.lockFile = ./Cargo.lock;

				passthru = {
					shellPath = "/bin/slash";
				};
			}
