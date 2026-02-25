{
  description = "pagedMov's NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/a5ebaf35f8930361787bb491d49fc2e807e6d51e";
    hypr-contrib.url = "github:hyprwm/contrib";
    copyparty.url = "github:9001/copyparty";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    stylix.url = "github:danth/stylix";
    disko.url = "github:nix-community/disko";
    shed.url = "github:km-clay/shed";

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

  outputs = { ... }@inputs:
    let
      movLib = import ./lib {
        inherit inputs;
        username = "pagedmov";
      };

      hosts = movLib.foldHosts [
        {
          host = "oganesson";
          hostDir = "desktop";
          kind = "both";
        }
        {
          host = "mercury";
          hostDir = "laptop";
          kind = "both";
        }
        {
          host = "xenon";
          hostDir = "server";
          kind = "both";
          extraNixosModules = [
            ./modules/server
          ];
        }
        {
          host = "phosphorous";
          hostDir = "work";
          kind = "both";
          extraNixosModules = [
            inputs.shed.nixosModules.shed
            inputs.copyparty.nixosModules.default
          ];
          extraHomeModules = [
            inputs.shed.homeModules.shed
          ];
          extraOverlays = [
            inputs.shed.overlays.default
            inputs.copyparty.overlays.default
          ];
        }
      ];
    in {
      inherit (hosts) nixosConfigurations homeConfigurations;
    };
}
