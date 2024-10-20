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
    home-manager,
    self,
    nixvim,
    stylix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "pagedmov";
		wallpaper = "${self}/media/wallpapers/cabin-2.jpg";

		# Base 16 scheme for system colors
		scheme = {
			"base00" = "151515";
			"base01" = "202020";
			"base02" = "303030";
			"base03" = "505050";
			"base04" = "b0b0b0";
			"base05" = "d0d0d0";
			"base06" = "e0e0e0";
			"base07" = "f5f5f5";
			"base08" = "fb9fb1";
			"base09" = "eda987";
			"base0A" = "ddb26f";
			"base0B" = "acc267";
			"base0C" = "12cfc0";
			"base0D" = "6fc2ef";
			"base0E" = "e1a3ee";
			"base0F" = "deaf8f";
		};
  in {
    nixosConfigurations = {
      oganesson = nixpkgs.lib.nixosSystem {
        specialArgs = {
          host = "oganesson";
          inherit self inputs scheme wallpaper username;
        };
        inherit system;
        modules = [
          ./hosts/desktop
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
          ./hosts/laptop
          stylix.nixosModules.stylix
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
        ];
      };
    };
  };
}
