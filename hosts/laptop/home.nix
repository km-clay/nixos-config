{
  host,
  pkgs,
  self,
  inputs,
  username,
  lib,
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
    extraSpecialArgs = {inherit self inputs host username nur;};
    users = {
      ${username} = {
        programs.home-manager.enable = true;
        imports = [
          inputs.self.outputs.homeManagerModules.default
        ];

        # My custom home-manager modules

        # modules/home/files
        homeFiles.enable = true;

        # modules/home/environment
        hyprlandConfig.enable   = true;
        autojumpConfig.enable   = true;
        stylixHomeConfig.enable = true;
        waybarConfig.enable     = true;
        gtkConfig.enable        = true;
        spicetifyConfig.enable  = true;
        starshipConfig.enable   = true;

        # modules/home/programs
        btopConfig.enable       = true;
        swayncConfig.enable     = true;
        userPkgs.enable         = true;
        cavaConfig.enable       = true;
        ezaConfig.enable        = true;
        firefoxConfig.enable    = true;
        fuzzelConfig.enable     = true;
        fzfConfig.enable        = true;
        gitConfig.enable        = true;
        kittyConfig.enable      = true;
        yaziConfig.enable       = true;
        zshConfig.enable        = true;
        passConfig.enable       = true;
        batConfig.enable        = true;

        # modules/home/scripts
        movScripts.enable = true;
        movScripts.commandScripts.enable = true;
        movScripts.hyprlandControls.enable = true;
        movScripts.nixShortcuts.enable = true;

        dconf.settings = lib.mkIf config.movOpts.virtConfig.enable {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = ["qemu:///system"];
            uris = ["qemu:///system"];
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
