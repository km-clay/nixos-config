{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gtrash
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
