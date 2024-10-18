{
	config,
		inputs,
		pkgs,
		username,
		self,
		host,
		...
}: let
nur = config.nur;
in {
	imports = [inputs.home-manager.nixosModules.home-manager];
	home-manager = {
		useUserPackages = true;
		useGlobalPkgs = true;
		backupFileExtension = "backup";
		extraSpecialArgs = {inherit self inputs host username nur;};
		users.${username} = {
			dconf.settings = {
				"org/virt-manager/virt-manager/connections" = {
					autoconnect = ["qemu:///system"];
					uris = ["qemu:///system"];
				};
			};
			programs.home-manager.enable = true;
			imports = [
					./../../home
			];
			home = {
				username = "${username}";
				homeDirectory = "/home/${username}";
				stateVersion = "24.05";
				pointerCursor = {
					name = "Quintom_Ink";
					size = 36;
					package = pkgs.quintom-cursor-theme;
				};
			};
		};
	};
	users = {
		groups.persist = {};
		users = {
			root.initialPassword = "1234";
			${username} = {
				isNormalUser = true;
				initialPassword = "1234";
				shell = pkgs.zsh;
				extraGroups = ["wheel" "persist" "libvirtd"];
			};
		};
	};
	security.sudo.extraConfig = ''
		${username} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild
		'';
	nix.settings.allowed-users = ["${username}"];
}
