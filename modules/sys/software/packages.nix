{lib, config, pkgs, inputs, ... }: {
  options = {
    sysPkgs.enable = lib.mkEnableOption "enables default system packages";
  };
  config = lib.mkIf config.sysPkgs.enable {
    environment.systemPackages = with pkgs; [
      alsa-lib
      alsa-utils
      bc
      cliphist
      fail2ban
      git
      hyprland-workspaces
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
      wl-clipboard
      libnotify
      file
      libvirt-glib
    ];
  };
}
