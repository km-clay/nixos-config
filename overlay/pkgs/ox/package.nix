{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
				pname = "ox";
				version = "v0.3.0-alpha_16aa803";

				  src = pkgs.fetchFromGitHub {
    owner = "pagedMov";
    repo = "ox";
    rev = "16aa803faad2db175298f75278947b91b1e91267";
    hash = "sha256-qhH6gPETDIMgRHtWPwmiwalsT1kAqx0ODtlWStVP1d0=";
  };
  

				doCheck = false; # TODO: Find a way to make tests work

				cargoLock.lockFile = ./Cargo.lock;

				passthru = {
					shellPath = "/bin/ox";
				};
			}
