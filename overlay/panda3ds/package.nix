{
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  lib
}:

stdenvNoCC.mkDerivation rec {
  pname = "panda3ds-qt";
  version = "0.8";

  src = fetchzip {
    url = "https://github.com/wheremyfoodat/Panda3DS/releases/download/v${version}/Linux-Qt.zip";
    sha256 = "1629yaa4xf7di0lmb5jwdggwpsrxcnlcj122px6qyvkmg8fa5q7m";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
      install -Dm755 Alber-x86_64.AppImage $out/bin
    runHook postInstall
  '';

  meta = {
    description = "";
    homepage = "";
    mainProgram = "";
    maintainers = "";
    platforms = lib.platforms.linux;
  };
}
