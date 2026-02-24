{ lib, config, pkgs, inputs, ... }: {
  options = {
    movOpts.softwareCfg.sysPkgs.enable =
      lib.mkEnableOption "enables default system packages";
  };
  config =
  let
    shed = inputs.shed.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in
  lib.mkIf config.movOpts.softwareCfg.sysPkgs.enable {
    environment.systemPackages = with pkgs; [
      dotnetCorePackages.sdk_8_0_4xx
      alsa-lib
      xwayland
      shed
      wayland
      alsa-utils
      bc
      cliphist
      fail2ban
      git
      gcc
      zip
      unzip
      hyprland-workspaces
      hyprpaper
      hyprpicker
      inetutils
      rcon-cli
      kitty
      lolcat
      lsof
      neofetch
      nh
      nix-index
      nix-output-monitor
      nix-prefetch-scripts
      nixos-option
      nix-search-cli
      nix-template
      nixfmt
      sshfs
      nvd
      pamixer
      pavucontrol
      playerctl
      usbutils
      vim
      uhk-agent
      jq
      jinja2-cli
      socat
      python3
      python313Packages.jinja2
      python313Packages.pillow
      ffmpeg
      wl-clipboard
      cmake
      libnotify
      gnumake
      file
      pkg-config
      openssl
      libvirt-glib
      man-pages
      man-pages-posix
      most
      wget
    ];
  };
}
