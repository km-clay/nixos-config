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
        ({
          host = "brinstar";
          hostDir = "desktop";
          kind = "both";
        } // defaultExtras)
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

      exports = (import ./exports { inherit inputs movLib; });
    in
    {
      inherit (hosts) nixosConfigurations homeConfigurations;
      inherit (exports) homeModules nixosModules devShells packages;
    };
}
