{
  host,
  pkgs,
  self,
  inputs,
  lib,
  username,
  config,
  ...
}: let
  nur = config.nur;
  movModules = inputs.self.outputs.homeManagerModules.default;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit self inputs host username nur; };
    users = {
      ${username} = {
        programs.home-manager.enable = true;
        imports = [ movModules ];
        autojumpConfig.enable            = true;
        btopConfig.enable                = true;
        starshipConfig.enable            = true;
        ezaConfig.enable                 = true;
        fzfConfig.enable                 = true;
        gitConfig.enable                 = true;
        yaziConfig.enable                = true;
        zshConfig.enable                 = true;
        batConfig.enable                 = true;
        userPkgs.enable                  = true;

        movScripts = {
          enable = true;
          nixShortcuts.enable = true;
          commandScripts = {
            enable = true;
            toolbelt.enable = false;
          };
          hyprlandControls = {
            scheck.enable = true;
          };
        };

        home = {
          username = "${username}";
          homeDirectory = "/home/${username}";
          stateVersion = "24.05";
        };
      };
    };
  };

  users = {
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        createHome = true;
        home = "/home/pagedmov";
        homeMode = "755";
        initialPassword = "1234";
        shell = pkgs.zsh;
        extraGroups = [ "wheel" ];
      };
      jellyfin.extraGroups = [ "users" ];
    };
  };
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = ["${username}"];
}
