{ lib, config, pkgs, inputs, ... }: {
  options = {
    movOpts.softwareCfg.sysPkgs.enable =
      lib.mkEnableOption "enables default system packages";
  };
  config = lib.mkIf config.movOpts.softwareCfg.sysPkgs.enable {
    environment.systemPackages = with pkgs; [
      alsa-lib
      xwayland
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
      nixfmt-classic
      sshfs
      nvd
      pamixer
      pavucontrol
      playerctl
      usbutils
      vim
      uhk-agent
      jq
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
    ];
  };
}
