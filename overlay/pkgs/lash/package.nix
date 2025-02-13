{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
				pname = "lash";
				version = "v0.5.0_5c038fb";

				  src = pkgs.fetchFromGitHub {
    owner = "pagedMov";
    repo = "lash";
    rev = "5c038fbb569fdad802f22fa0bd5ca9a839dcaed8";
    hash = "sha256-AGItl4LN8hWqcNmE6d9snIkaV/FZKKD58e2pf7A22UA=";
  };
  

				doCheck = false; # TODO: Find a way to make tests work

				cargoLock.lockFile = ./Cargo.lock;

				passthru = {
					shellPath = "/bin/lash";
				};
			}
