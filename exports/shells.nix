{ inputs }:

{
  devShells = {
    x86_64-linux = {
      default =
      let
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
          overlays = [
            inputs.shed.overlays.default
            inputs.copyparty.overlays.default
          ];
        };
        homeCfg = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            inputs.self.homeModules.default
            {
              movOpts.homeConfig.enableProfiles = [ "cli" ];
            }
          ];
        };
        nixvim = homeCfg.config.programs.nixvim.build.package;
      in pkgs.mkShell {
        packages = [ nixvim ] ++ homeCfg.config.home.packages;
        shellHook = "exec ${pkgs.shed}/bin/shed";
      };
    };
  };
}
