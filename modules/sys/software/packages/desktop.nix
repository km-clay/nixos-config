args:
let
  inherit (args) pkgs;
in
{
  environment.systemPackages = with pkgs; [
    xwayland
    wayland
    hyprland-workspaces
    hyprpaper
    hyprpicker
    cliphist
    wl-clipboard
    kitty
    pamixer
    pavucontrol
    playerctl
    libnotify
    fastfetch
    lolcat
    alsa-lib
    alsa-utils
    uhk-agent
  ];

  programs = {
    hyprland.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        ffmpeg-full
      ];
    };
  };

  services = {
    davfs2.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
    ratbagd.enable = true;
    blueman.enable = true;
    mullvad-vpn.enable = true;
  };
}
