{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "fzf-tab";
  version = "v1.1.2";
  src = pkgs.fetchFromGitHub {
    owner = "Aloxaf";
    repo = "fzf-tab";
    rev = "6aced3f35def61c5edf9d790e945e8bb4fe7b305";
    hash = "sha256-EWMeslDgs/DWVaDdI9oAS46hfZtp4LHTRY8TclKTNK8=";
  };

  installPhase = ''
    cp -r $src $out
  '';
}
