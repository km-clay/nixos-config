{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "noto-sans-jp";
  version = "0.0.1";

  src = ../../../assets/fonts/Noto_Sans_JP.zip;

  buildInputs = [
    pkgs.unzip
  ];

  installPhase = ''
    runHook preInstall

    unzip $src

    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/share/doc/${pname}

    install -Dm644 ./static/*.ttf $out/share/fonts/truetype
    install -Dm644 *.ttf $out/share/fonts/truetype
    install -Dm644 *.txt $out/share/doc/${pname}

    runHook postInstall
  '';
}
