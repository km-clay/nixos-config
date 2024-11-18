{ lib, pkgs, modulesPath, inputs, ... }:

let
  userConfig = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$OobgblSbriz8BMgqKXk8Q/$FlTKe918WI3e5m3sj0dDGO.R/rmJOqcscVZMtN5a/DD";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };
in
{
  imports = [ ./hardware.nix ];
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  movOpts = {
    sysEnv = {
      issue.enable = true;
      stylixConfig.enable = true;
      nixSettings.enable = true;
    };
    hardwareCfg = {
      networkModule.enable = true;
      bootLoader.enable = true;
    };
    softwareCfg = {
      sysProgs.enable = true;
      sysServices.enable = true;
    };
  };

  environment.systemPackages = with pkgs;[
    alsa-lib
    xwayland
    wayland
    alsa-utils
    bc
    cliphist
    git
    hyprpaper
    hyprpicker
    inetutils
    kitty
    lsof
    neofetch
    nh
    nix-output-monitor
    nix-prefetch-scripts
    nixos-option
    nix-search-cli
    nix-template
    nixfmt
    nvd
    pamixer
    pavucontrol
    playerctl
    usbutils
    vim
    jq
    wl-clipboard
    libnotify
    file
  ];

  users = {
    groups.persist = { };
    users = {
      impermanence = userConfig;
      persistence = userConfig // {
        extraGroups = userConfig.extraGroups ++ [ "persist" ];
      };
      root.hashedPassword = "$y$j9T$tjpyEif7XNctN0twWipqc/$hfVGMaVYVP7.gjqG.2eV34j2AoWp2AFBxox7B5QyQy3";
    };
  };
}
