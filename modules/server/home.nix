{ pkgs, inputs, config, host, self, ... }: {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit host self inputs;};
    users."pagedmov" = {
      programs.home-manager.enable = true;
      imports = [
        ../home/environment/zshell.nix
        ../home/environment/starship.nix
        ../home/programs/eza.nix
        ../home/scripts
      ];
      home = {
        username = "pagedmov";
        homeDirectory = "/home/pagedmov";
        stateVersion = "24.05";
      };
    };
  };
  users.users = {
    pagedmov = {
      isNormalUser = true;
      initialPassword = "1234";
      extraGroups = ["wheel"];
    };
    root.initialPassword = "1234";
  };
}
