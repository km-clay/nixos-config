{
  stdenv,
  fetchFromGitHub,
  lib,
}:

let
  pagedMov = {
    email = "kylerclay@proton.me";
    github = "pagedMov";
    githubId = 19557376;
    name = "Kyler Clay";
    keys = [ { fingerprint = "784B 3623 94E7 8F11 0B9D AE0F 56FD CFA6 2A93 B51E"; } ];
  };
in
stdenv.mkDerivation {
  pname = "tinyfetch";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "abrik1";
    repo = "tinyfetch";
    rev = "refs/tags/0.2";
    hash = "sha256-nuC7Xtfg7rf6/IDhUKT2JZD9V0Hl/welNAFDJYJKwmA=";
  };

  buildPhase = ''
    runHook preBuild
    $CC src/tinyfetch.c -o tinyfetch
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 tinyfetch -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Simple fetch in C which is tiny and fast";
    homepage = "https://github.com/abrik1/tinyfetch";
    license = lib.licenses.mit;
    mainProgram = "tinyfetch";
    maintainers = [ pagedMov ];
    platforms = lib.platforms.unix;
  };
}
