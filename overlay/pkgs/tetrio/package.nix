{
  pkgs ? import <nixpkgs> { },
}:

let
  tetrio-version = "10";
  tetrio-src = pkgs.fetchzip {
    url = "https://tetr.io/about/desktop/builds/${tetrio-version}/TETR.IO%20Setup.deb";
    hash = "sha256-2FtFCajNEj7O8DGangDecs2yeKbufYLx1aZb3ShnYvw=";
    nativeBuildInputs = [ pkgs.dpkg ];
  };
  tetrio-plus = pkgs.stdenv.mkDerivation rec {
    pname = "tetrio-plus";
    version = "0.28.1";

    src = pkgs.fetchFromGitLab {
      owner = "UniQMG";
      repo = "tetrio-plus";
      rev = "681bf0e59448e6c512f4367770a973b1945b7759";
      hash = "sha256-+yOqHH/RtzjVKHVpVsw2RhECMskCyAyWnjBJNslbGaw=";
    };

    offlineCache = pkgs.fetchYarnDeps {
      yarnLock = "${src}/resources/desktop-ci/yarn.lock";
      hash = "sha256-ZU4ObEpJwnC71V5IemG5XWNbX/xvlWdKsXulus7ec5A=";
    };

    nativeBuildInputs = with pkgs; [
      yarn
      fixup-yarn-lock
      nodejs
      asar
    ];

    buildPhase = ''
      runHook preBuild

      asar extract "${tetrio-src}/opt/TETR.IO/resources/app.asar" out

      (
        cd out

        cp ../resources/desktop-ci/yarn.lock .
        patch package.json ../resources/desktop-ci/package.json.diff

        export HOME=$(mktemp -d)
        yarn config --offline set yarn-offline-mirror ${offlineCache}
        fixup-yarn-lock yarn.lock
        yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
        patchShebangs node_modules/
      )

      ln -s ${tetrio-src}/opt/TETR.IO/resources/app.asar app.asar
      node ./scripts/build-electron.js

      cp -r $src out/tetrioplus
      chmod -R u+w out/tetrioplus

      substituteInPlace out/tetrioplus/desktop-manifest.js \
        --replace-fail '"show_uninstaller_button": true' '"show_uninstaller_button": false'

      echo "nixpkgs" > out/tetrioplus/resources/override-commit

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      asar pack out $out

      runHook postInstall
    '';
  };

in pkgs.stdenvNoCC.mkDerivation {
  pname = "tetrio";
  version = tetrio-version;

  src = tetrio-src;

  nativeBuildInputs = [ pkgs.makeWrapper ];


  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share/ $out
    mkdir -p $out/share/TETR.IO/
    cp ${tetrio-plus} $out/share/TETR.IO/app.asar

    substituteInPlace $out/share/applications/TETR.IO.desktop \
      --replace-fail "Exec=/opt/TETR.IO/TETR.IO" "Exec=$out/bin/tetrio" \
      --replace-fail "StartupWMClass=TETR.IO" "StartupWMClass=tetrio-desktop"

    runHook postInstall
  '';

  postFixup = ''
  makeShellWrapper '${pkgs.lib.getExe pkgs.electron}' "$out/bin/tetrio" \
    --prefix LD_LIBRARY_PATH : ${pkgs.addDriverRunpath.driverLink}/lib \
    --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
    --add-flags "$out/share/TETR.IO/app.asar"
  '';
}
