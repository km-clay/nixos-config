# pagedMov's Custom Command Scripts

## icanhazip
	- Leverages ip and icanhazip.com to return relevant ip info for the current machine.
	- Usage:
		- `icanhazip` - returns public ip, local ip, and default gateway
		- `icanhazip -p` - returns only public ip
		- `icanhazip -l` - returns only local ip
		- `icanhazip -d` - returns only default gateway
	- Defined in 'modules/home/scripts/commands/icanhazip.nix'

## invoke
	- Leverages `nix run` to run any command once. Works with arguments.
	- Usage:
		- `invoke <command>`
	- Example:
		- `invoke hello`
	- Defined in 'modules/home/scripts/commands/invoke.nix'

## runbg
	- Runs a command and detaches the process from the shell silently. Works with arguments. Credit to [Frost-Phoenix](https://github.com/Frost-Phoenix) for writing this script.
	- Usage:
		- `runbg <command> <args>`
	- Example:
		- `runbg waybar`
	- Defined in 'modules/home/scripts/commands/runbg.nix'

## toolbelt
	- Opens a fuzzyfinder window with some useful utilities. Meant to be used with the Super + P bind defined in hyprland.nix, and not invoked directly from the shell.
	- Defined in 'modules/home/scripts/commands/toolbelt.nix'

## viconf
	- Searches the directory held in the $FLAKEPATH environment variable for a given nix file or directory name. Opens the file found in neovim, or if there are multiple matches, opens a fuzzyfinder window to allow you to choose one.
	- Usage:
		- `viconf <part of path or filename>`
	- Examples:
		- `viconf hyprland` - Opens $FLAKEPATH/modules/home/environment/hyprland.nix
		- `viconf sys` - Opens fuzzyfinder window containing all nix files in modules/sys and its subdirectories
		- `viconf config` - Opens fuzzyfinder window containing all nix files called 'config.nix'
		- `viconf scripts/def` - Opens $FLAKEPATH/modules/home/scripts/default.nix
	- Defined in 'modules/home/scripts/commands/viconf.nix'

## vipkg
	- Searches the pkgs directory from the nixpkgs github repository. Works almost identically to viconf with a few tweaks to accomodate the different directory structure. Useful for when you want to override a package's build attributes. Can also just be used to search for a package name.
	- Usage:
		- `vipkg <part of package name>`
	- Example:
		- `vipkg neofetch` - Opens nixpkgs/pkgs/tools/misc/neofetch/default.nix
	- Defined in 'modules/home/scripts/commands/vipkg.nix'
