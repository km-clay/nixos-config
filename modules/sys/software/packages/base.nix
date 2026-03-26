args:
let
  inherit (args) pkgs inputs username;
  shed = inputs.shed.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = with pkgs; [
    shed
    git
    gcc
    zip
    unzip
    vim
    jq
    file
    wget
    lsof
    bc
    inetutils
    usbutils
    socat
    sshfs
    man-pages
    man-pages-posix
    most
    age
    agenix-cli
    fail2ban
    jinja2-cli

    # nix tooling
    nix-index
    nix-output-monitor
    nix-prefetch-scripts
    nixos-option
    nix-search-cli
    nix-template
    nixfmt
    nvd
    nh
  ];

  programs = {
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services = {
    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          capslock = "esc";
        };
      };
    };
    openssh = {
      enable = true;
      allowSFTP = true;
    };
    pcscd.enable = true;
    udev.enable = true;
    dbus.enable = true;
  };

  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBX/xEA6/zfAkjwaDcl+NnCJLMd7OzRru7IKbn+52fi5 root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6QYwnaxkpeN7c1NH5u5z1lv4VqKKAaty2qJ2BXRcg2 pagedmov@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFWGaQKygNvvZ/qtR6QFxAA1HQQgoQPCoQbx/cyhEuC pagedmov@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICOg895UX4fT+1t7icEq5t9U7Ggd9HeDcgFBkyZ4/ghv root@nixos"
    ];
  };
}
