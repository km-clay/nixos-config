{
  description = "pagedMov's NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hypr-contrib.url = "github:hyprwm/contrib";
    copyparty.url = "github:9001/copyparty";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    stylix.url = "github:danth/stylix";
    disko.url = "github:nix-community/disko";
    fern.url = "github:km-clay/fern";

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
            inputs.fern.nixosModules.fern
            inputs.copyparty.nixosModules.default
          ];
          extraHomeModules = [
            inputs.fern.homeModules.fern
          ];
          extraOverlays = [
            inputs.fern.overlays.default
            inputs.copyparty.overlays.default
          ];
        }
      ];
    in {
      inherit (hosts) nixosConfigurations homeConfigurations;
    };
}
