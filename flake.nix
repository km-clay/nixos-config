{
  description = "pagedMov's NixOS configuration";

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

  outputs = {
    nixpkgs,
    nur,
    self,
    nixvim,
    stylix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "pagedmov";
  in {
    homeManagerModules.default = ./modules/home;
    nixosModules.default = ./modules/sys;
    serverModules.default = ./modules/server;
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

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
          nixvim.nixosModules.nixvim
          nur.nixosModules.nur
        ];
      };

      mercury = nixpkgs.lib.nixosSystem {
        specialArgs = {
          host = "mercury";
          inherit self inputs username;
        };
        modules = [
          ./hosts/laptop/config.nix
          ./modules/sys
          stylix.nixosModules.stylix
          nixvim.nixosModules.nixvim
          nur.nixosModules.nur
        ];
      };

      xenon = nixpkgs.lib.nixosSystem {
        specialArgs = {
          host = "xenon";
          inherit self inputs username;
        };
        modules = [
          ./hosts/server/config.nix
          ./modules/sys
          ./modules/server
          stylix.nixosModules.stylix
          nixvim.nixosModules.nixvim
          nur.nixosModules.nur
        ];
      };

      installer = nixpkgs.lib.nixosSystem {
        specialArgs = {
          host = "installer";
          inherit self inputs;
        };
        modules = [
          ./hosts/installer
          nixvim.nixosModules.nixvim
        ];
      };
    };
  };
}
