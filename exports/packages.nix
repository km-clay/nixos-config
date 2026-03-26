{ inputs }:

{
  packages = {
    x86_64-linux = {
      dev-home =
      let
        homeCfg = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config = { allowUnfree = true; };
            overlays = [
              inputs.shed.overlays.default
              inputs.copyparty.overlays.default
              (import "${inputs.self}/overlay/overlay.nix" {
                host = "external";
                root = inputs.self;
              })
            ];
          };
          modules = [
            inputs.self.homeModules.default
            {
              _module.args.username = "devmov";
              home.username = "devmov";
              home.homeDirectory = "/home/devmov";
            }
          ];
        };
      in homeCfg.config.home.activationPackage;
    };
  };
}
