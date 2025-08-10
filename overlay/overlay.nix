{ host ? "oganesson", root, ... }: self: super:

let
  extraFigletFonts = super.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "master";
    sha256 = "sha256-/Qj8CWqn7w1R83enixxgC5ijUrHvqN3C7ZvRCs/AzBI=";
  };
in
{
  toilet = super.toilet.overrideAttrs (old: {
    buildInputs = old.buildInputs or [ ] ++ [ extraFigletFonts ];

    installPhase = ''
      make install PREFIX=$out
      mkdir -p $out/share/figlet
      cp -r ${extraFigletFonts}/* $out/share/figlet
    '';
  });
  myPkgs = {
    # Packages that I've made
    slash = super.callPackage ./pkgs/slash/package.nix {};
    fzf-tab = super.callPackage ./pkgs/zsh-fzf-tab/package.nix {};
  };
  myScripts = import ./scripts { inherit super root host; };
}
