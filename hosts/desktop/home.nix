{
  host,
  pkgs,
  self,
  inputs,
  username,
  wallpaper,
  lib,
  scheme,
  config,
  ...
}: let
  nur = config.nur;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit self inputs host wallpaper scheme username nur;};
    users = {
      ${username} = {
        imports = [
          inputs.spicetify-nix.homeManagerModules.default
          inputs.self.outputs.homeManagerModules.default
        ];
        dconf.settings = lib.mkIf config.virtConfig.enable {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = ["qemu:///system"];
            uris = ["qemu:///system"];
          };
        };
        programs.home-manager.enable = true;
        home = {
          username = "${username}";
          homeDirectory = "/home/${username}";
          stateVersion = "24.05";
        };
      };
    };
  };

  users = {
    groups.persist = {};
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.zsh;
        extraGroups = ["wheel" "persist" "libvirtd"];
      };
    };
  };
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = ["${username}"];
}
