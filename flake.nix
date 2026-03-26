{
  description = "pagedMov's NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/5448eaf6c29de13e96d7461a4de4d66bf5931ec8";
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    hypr-contrib.url = "github:hyprwm/contrib";
    copyparty.url = "github:9001/copyparty";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    stylix.url = "github:danth/stylix";
    disko.url = "github:nix-community/disko";
    shed.url = "github:km-clay/shed";
    agenix.url = "github:ryantm/agenix";

    nixvim.url = "github:nix-community/nixvim";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };

    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { ... }@inputs:
    let
      movLib = import ./lib {
        inherit inputs;
        username = "pagedmov";
      };
      defaultExtras = {
          extraNixosModules = [
            inputs.shed.nixosModules.shed
            inputs.copyparty.nixosModules.default
            inputs.agenix.nixosModules.default
          ];
          extraHomeModules = [
            inputs.spicetify-nix.homeManagerModules.default
            inputs.shed.homeModules.shed
          ];
          extraOverlays = [
            inputs.shed.overlays.default
            inputs.copyparty.overlays.default
          ];
      };

      hosts = movLib.foldHosts [
        {
          host = "brinstar";
          hostDir = "desktop";
          kind = "both";
        }
        ({
          host = "kraid";
          hostDir = "laptop";
          kind = "both";
        } // defaultExtras)
        ({
          host = "tourian";
          hostDir = "work";
          kind = "both";
        } // defaultExtras)
      ];
    in
    {
      inherit (hosts) nixosConfigurations homeConfigurations;

      # this exposes the home manager framework as a flake output
      # which makes it possible to arbitrarily reproduce my environment anywhere
      homeModules.default = {
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
          ./modules/home
          {
            home.username = lib.mkDefault "pagedmov";
            home.homeDirectory = lib.mkDefault "/home/pagedmov";
            home.stateVersion = lib.mkDefault "24.05";

            movOpts.homeConfig.enableProfiles = lib.mkDefault [ "cli" ];
          }
        ];
      };

      # an example usage of self.homeModules.default;
      packages.x86_64-linux.dev-home = let
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
}
