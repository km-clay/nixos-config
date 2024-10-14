{ host, nur, self, inputs, username, config, ... }:




{
	imports = 
		[ (import ./programs/btop.nix) 	             ]
	 ++ [ (import ./programs/yazi.nix)               ]
	 ++ [ (import ./programs/kitty.nix)              ]
	 ++ [ (import ./programs/fuzzel.nix)             ]
	 ++ [ (import ./programs/eza.nix) 	             ]
	 ++ [ (import ./programs/cava.nix) 	             ]
	 ++ [ (import ./programs/bat.nix) 	             ]
	 ++ [ (import ./programs/git.nix) 	             ]
	 ++ [ (import ./environment/gtk.nix) 	         ]
	 ++ [ (import ./environment/spicetify.nix)       ]
	 ++ [ (import ./environment/starship.nix)        ]
	 ++ [ (import ./environment/laptop_userpkgs.nix) ]
	 ++ [ (import ./environment/zshell.nix)          ]
	 ++ [ (import ./firefox/firefox.nix)             ]
	 ++ [ (import ./hyprland)                        ]
	 ++ [ (import ./scripts ) 				         ]
	 ++ [ (import ./swaync/swaync.nix)               ]
	 ++ [ (import ./waybar) 	                     ];
}
