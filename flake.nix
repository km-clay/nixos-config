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

  outputs = { self, home-manager, ghostty, disko, nixpkgs, impermanence, nixvim, stylix, ... }@inputs:
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
            stylix.homeManagerModules.stylix
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
            stylix.homeManagerModules.stylix
            nixvim.homeManagerModules.nixvim
          ];
        };
        neonImpermanenceHome = let host = "neonImpermanence"; in home-manager.lib.homeManagerConfiguration { # Live Environment
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
            ./modules/home
            (import ./hosts/live-env/home.nix { username = "impermanence"; })
            nixvim.homeManagerModules.nixvim
            stylix.homeManagerModules.stylix
          ];
        };
        neonPersistenceHome = let host = "neonPersistence"; in home-manager.lib.homeManagerConfiguration { # Live Environment
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
            ./modules/home
            (import ./hosts/live-env/home.nix { username = "persistence"; })
            nixvim.homeManagerModules.nixvim
            stylix.homeManagerModules.stylix
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
          };
          modules = [
            ./hosts/desktop/config.nix
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
        neon = nixpkgs.lib.nixosSystem { # Live environment
          specialArgs = {
            host = "neon";
            inherit self inputs;
          };
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [];
          };
          modules = [
            ./hosts/live-env/config.nix
            (import ./hosts/live-env/disko.nix { device = "/dev/sdd"; })
            ./modules/sys
            disko.nixosModules.default
            nixvim.nixosModules.nixvim
            impermanence.nixosModules.impermanence
            stylix.nixosModules.stylix
          ];
        };
      };
    };
}
