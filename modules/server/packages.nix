{ pkgs, ... }:
let
  extraFigletFonts = pkgs.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "master";
    sha256 = "sha256-dAs7N66D2Fpy4/UB5Za1r2qb1iSAJR6TMmau1asxgtY=";
  };
  toilet-extrafonts = pkgs.toilet.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs or [] ++ [extraFigletFonts];

    installPhase = ''
      make install PREFIX=$out
      mkdir -p $out/share/figlet
      cp -r ${extraFigletFonts}/* $out/share/figlet
    '';
  });
in
{
  environment.systemPackages = with pkgs; [
    toilet-extrafonts
    gtrash
    alsa-utils
    python3
    fail2ban
    inetutils
    lolcat
    lsof
    mullvad
    neofetch
    nh
    nix-output-monitor
    nix-prefetch-scripts
    nixos-option
    nix-search-cli
    openssl
    p7zip
    jq
    git
    pamixer
    parted
    pkg-config
    socat
    sox
    stress
    tree
    unrar
    unzip
    usbutils
  ];
}
