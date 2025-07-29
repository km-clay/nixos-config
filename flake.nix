{
  description = "pagedMov's NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    stylix.url = "github:danth/stylix";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    ghostty.url = "github:ghostty-org/ghostty";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = { self, home-manager, disko, nixpkgs, impermanence, nixvim, stylix, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "pagedmov";
      nixpkgsConfig = {
        allowUnfree = true;
      };
    in {
      homeConfigurations = {
        oganessonHome = let host = "oganesson"; in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [
              (import ./overlay/overlay.nix { inherit host; root = self; })
            ];
          };
          extraSpecialArgs = {
            inherit host self username inputs;
          };

          modules = [
            ./hosts/desktop/home.nix
            ./modules/home
            stylix.homeModules.stylix
            nixvim.homeManagerModules.nixvim
          ];
        };
        phosphorousHome = let host = "phosphorous"; in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [
              (import ./overlay/overlay.nix { inherit host; root = self; })
            ];
          };
          extraSpecialArgs = {
            inherit host self username inputs;
          };

          modules = [
            ./hosts/work/home.nix
            ./modules/home
            stylix.homeManagerModules.stylix
            nixvim.homeManagerModules.nixvim
          ];
        };

        mercuryHome = let host = "mercury"; in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [
              (import ./overlay/overlay.nix { inherit host; root = self; })
            ];
          };
          extraSpecialArgs = {
            inherit host self username inputs;
          };

          modules = [
            ./hosts/laptop/home.nix
            ./modules/home
            stylix.homeModules.stylix
            nixvim.homeManagerModules.nixvim
          ];
        };

        xenonHome = let host = "xenon"; in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [
              (import ./overlay/overlay.nix { inherit host; root = self; })
            ];
          };
          extraSpecialArgs = {
            inherit host self username inputs;
          };

          modules = [
            ./hosts/server/home.nix
            ./modules/home
            stylix.homeModules.stylix
            nixvim.homeManagerModules.nixvim
          ];
        };
      };

      nixosConfigurations = {
        oganesson = nixpkgs.lib.nixosSystem { # Desktop
          specialArgs = {
            inherit self inputs username;
            host = "oganesson";
            overlays = [
              (import ./overlay/overlay.nix { root = self; })
            ];
          };
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [
              (import ./overlay/overlay.nix { root = self; })
            ];
          };
          modules = [
            ./hosts/desktop/config.nix
            ./modules/sys
            stylix.nixosModules.stylix
          ];
        };

        phosphorous = nixpkgs.lib.nixosSystem { # Desktop
          specialArgs = {
            inherit self inputs username;
            host = "oganesson";
            overlays = [
              (import ./overlay/overlay.nix { root = self; })
            ];
          };
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [
              (import ./overlay/overlay.nix { root = self; })
            ];
          };
          modules = [
            ./hosts/work/config.nix
            ./modules/sys
            stylix.nixosModules.stylix
          ];
        };

        mercury = nixpkgs.lib.nixosSystem { # Laptop
          specialArgs = {
            inherit self inputs username;
            host = "mercury";
          };
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
          };
          modules = [
            ./hosts/laptop/config.nix
            ./modules/sys
            stylix.nixosModules.stylix
          ];
        };

        xenon = nixpkgs.lib.nixosSystem { # Server
          specialArgs = {
            inherit self inputs username;
            host = "xenon";
          };
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
          };
          modules = [
            ./hosts/server/config.nix
            ./modules/sys
            ./modules/server
            stylix.nixosModules.stylix
          ];
        };
      };
    };
}
