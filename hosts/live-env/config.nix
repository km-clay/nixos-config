{ lib, pkgs, modulesPath, inputs, ... }:

let
  userConfig = {
    isNormalUser = true;
    initialPassword = "1234";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };
in
{
  imports = [ ./hardware.nix ];

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
      root.initialPassword = "1234";
    };
  };
}
