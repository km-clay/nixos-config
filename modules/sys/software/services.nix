{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    movOpts.softwareCfg.sysServices.enable = lib.mkEnableOption "enables default system services";
  };
  config = lib.mkIf config.movOpts.softwareCfg.sysServices.enable {
    users.users.pagedmov = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBX/xEA6/zfAkjwaDcl+NnCJLMd7OzRru7IKbn+52fi5 root@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6QYwnaxkpeN7c1NH5u5z1lv4VqKKAaty2qJ2BXRcg2 pagedmov@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFWGaQKygNvvZ/qtR6QFxAA1HQQgoQPCoQbx/cyhEuC pagedmov@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICOg895UX4fT+1t7icEq5t9U7Ggd9HeDcgFBkyZ4/ghv root@nixos"
      ];
    };
    services = {
      davfs2.enable = true;
      keyd = {
        enable = true;
        keyboards.default = {
          ids = [ "*" ];
          settings.main = {
            capslock = "esc";
          };
        };
      };
      copyparty = {
        enable = true;
        settings = {
          e2dsa = true;
        };
        accounts = {
          admin = {
            passwordFile = "${pkgs.writeText "/run/keys/admin" "admin123"}";
          };
          pagedmov = {
            passwordFile = "${pkgs.writeText "/run/keys/pagedmov" "200231980qwertyuiop"}";
          };
          testuser = {
            passwordFile = "${pkgs.writeText "/run/keys/testuser" "testpassword"}";
          };
        };
        volumes = {
          "/" = {
            path = "/var/lib/copyparty";
            access = {
              A = [ "admin " ];
              rwmd = [ "pagedmov" ];
            };
          };
          "/testvol" = {
            path = "/var/lib/copyparty/testvol";
            access = {
              A = [ "admin " ];
              rwmd = [ "testuser" ];
            };
          };
        };
      };
      pipewire = {
        enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
      };
      openssh = {
        enable = true;
        allowSFTP = true;
      };
      ratbagd.enable = true;
      pcscd.enable = true;
      udev.enable = true;
      dbus.enable = true;
      mullvad-vpn.enable = true;
      blueman.enable = true;
    };
  };
}
