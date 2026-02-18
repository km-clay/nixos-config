{ host ? "oganesson", root, ... }: self: super:

let
  extraFigletFonts = super.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "master";
    sha256 = "sha256-wT1DjM+3+UasAm2IHavBXs0R8eNMJn9uLtWSqwS+XU0=";
  };
  vicutSrc = super.fetchFromGitHub {
    owner = "km-clay";
    repo = "vicut";
    rev = "v0.4.2";
    sha256 = "sha256-y5H4m/1ZNYkvhYnfvKs2zVq6dzUgUYsu0UCBGpcoYgQ=";
  };
in {
  vicut = super.rustPlatform.buildRustPackage {
    pname = "vicut";
    version = "v0.4.2";

    src = vicutSrc;
    cargoLock.lockFile = "${vicutSrc}/Cargo.lock";

    meta = {
      description = "A Vim-based, scriptable, headless text editor for the command line";
      homepage = "https://github.com/km-clay/vicut";
      license = super.lib.licenses.mit;
      maintainers = [];
    };
  };

  toilet = super.toilet.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ extraFigletFonts ];

    installPhase = ''
      make install PREFIX=$out
      mkdir -p $out/share/figlet
      cp -r ${extraFigletFonts}/* $out/share/figlet
    '';
  });

  myPkgs = {
    slash = super.callPackage ./pkgs/slash/package.nix {};
    fzf-tab = super.callPackage ./pkgs/zsh-fzf-tab/package.nix {};
    noto-sans-jp = super.callPackage ./pkgs/noto-sans-jp/package.nix {};
    billy-font = super.callPackage ./pkgs/billy-font/package.nix {};
  };

  myScripts = import ./scripts { inherit super root host; };
}
