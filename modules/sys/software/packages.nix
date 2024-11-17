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
      hyprland-workspaces
      hyprpaper
      hyprpicker
      inetutils
      kitty
      lolcat
      lsof
      mpd
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
      tor
      usbutils
      vim
      wine
      uhk-agent
      obs-studio
      jq
      wl-clipboard
      libnotify
      file
      libvirt-glib
    ];
  };
}
