{
  description = "pagedMov's NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    stylix.url = "github:danth/stylix";

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

  outputs = { self, home-manager, nixpkgs, nur, nixvim, stylix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ./overlay/overlay.nix) ];
      };
      username = "pagedmov";
    in {
      inherit pkgs;
      homeConfigurations = {
        oganessonHome = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            host = "oganesson";
            inherit self username inputs;
          };

          modules = [
            ./hosts/desktop/home.nix
            ./modules/home
            stylix.homeManagerModules.stylix
            nixvim.homeManagerModules.nixvim
            nur.nixosModules.nur
          ];
        };

        mercuryHome = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            host = "oganesson";
            inherit self username inputs;
          };

          modules = [
            ./hosts/laptop/home.nix
            ./modules/home
            stylix.homeManagerModules.stylix
            nixvim.homeManagerModules.nixvim
            nur.nixosModules.nur
          ];
        };

        xenonHome = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            host = "oganesson";
            inherit self username inputs;
          };

          modules = [
            ./hosts/server/home.nix
            ./modules/home/servermodule.nix
            nixvim.homeManagerModules.nixvim
          ];
        };
      };

      nixosConfigurations = {
        oganesson = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "oganesson";
            inherit self inputs username;
          };
          inherit system;
          modules = [
            ./hosts/desktop/config.nix
            ./modules/sys
            stylix.nixosModules.stylix
            nur.nixosModules.nur
          ];
        };

        mercury = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "mercury";
            inherit self inputs username;
          };
          inherit system;
          modules = [
            ./hosts/laptop/config.nix
            ./modules/sys
            stylix.nixosModules.stylix
            nur.nixosModules.nur
          ];
        };

        xenon = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "xenon";
            inherit self inputs username;
          };
          inherit system;
          modules = [
            ./hosts/server/config.nix
            ./modules/sys
            ./modules/server
            stylix.nixosModules.stylix
            nur.nixosModules.nur
          ];
        };

        installer = nixpkgs.lib.nixosSystem {
          specialArgs = {
            host = "installer";
            inherit self inputs;
          };
          inherit system;
          modules = [ ./hosts/installer nixvim.nixosModules.nixvim ];
        };
      };
    };
}
