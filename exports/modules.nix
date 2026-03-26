{ inputs, movLib, ... }:

{
  homeModules = {
    default = {
      lib,
      ...
    }: {
      _module.args = {
        inherit (inputs) self;
        inherit movLib inputs;
        host = lib.mkDefault "external";
        username = lib.mkDefault "pagedmov";
      };
      imports = [
        inputs.shed.homeModules.shed
        inputs.spicetify-nix.homeManagerModules.default
        inputs.stylix.homeModules.stylix
        inputs.nixvim.homeModules.nixvim
        "${inputs.self}/modules/home"
        {
          home.username = lib.mkDefault "pagedmov";
          home.homeDirectory = lib.mkDefault "/home/pagedmov";
          home.stateVersion = lib.mkDefault "24.05";

          movOpts.homeConfig.enableProfiles = lib.mkDefault [ "cli" ];
        }
      ];
    };
  };

  nixosModules = {
    # None yet
  };
}
