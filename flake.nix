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
		wallpaper = "${self}/assets/wallpapers/sleeping.png";
		base16scheme = "nord"; # can be easily changed with the chscheme script

    # Map colors from yaml to attribute set
		# Extracting colors into a set here allows them to be propagated across the entire config, with or without stylix
		lib = nixpkgs.lib;
		pkgs = import nixpkgs { system = "x86_64-linux"; };
    scheme_path = "${pkgs.base16-schemes}/share/themes/${base16scheme}.yaml";
		scheme_string = builtins.readFile scheme_path;
    scheme_list = lib.splitString "\n" "${scheme_string}";
    colors = lib.filter (line: builtins.match "^ *base[0-9A-F]{2}: .*" line != null) scheme_list;
    scheme = lib.lists.foldl' (acc: line:
        let
            splitLine = lib.splitString ": " line;
            key = builtins.elemAt splitLine 0;
            value = builtins.elemAt splitLine 1;
            trimmedKey = lib.trim key;
            cleanValue_step1 = lib.splitString " " value;
            cleanValue_step2 = builtins.elemAt cleanValue_step1 0;
            cleanValue_final = builtins.substring 1 (builtins.stringLength cleanValue_step2 - 2) cleanValue_step2;
        in
            acc // { "${trimmedKey}" = cleanValue_final; }
        ) {} colors;
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
          inherit self inputs scheme wallpaper username;
        };
        modules = [
          ./hosts/laptop
          stylix.nixosModules.stylix
					nixvim.nixosModules.nixvim
          nur.nixosModules.nur
        ];
      };

      xenon = nixpkgs.lib.nixosSystem {
        specialArgs = {
          host = "xenon";
          inherit self inputs scheme wallpaper username;
        };
        modules = [
          ./hosts/server
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
