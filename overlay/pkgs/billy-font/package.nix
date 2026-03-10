{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenvNoCC.mkDerivation {
  pname = "billy-font";
  version = "0.0.1";

  src = ../../../assets/fonts/Billyfont.zip;

  buildInputs = [
    pkgs.unzip
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype

    unzip $src -d $out/share/fonts/truetype

    runHook postInstall
  '';
}
