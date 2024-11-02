# System Options

## networkModule.enable
	- Enables my network configuration
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/hardware/network.nix'

## nixSettings.enable
	- Enables my NixOS settings
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/environment/nix.nix'

## bootLoader.enable
	- Enables my bootloader settings
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/hardware/bootloader.nix'

## issue.enable
	- Enables my custom /etc/issue tty splash screen
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/environment/issue.nix'

## sddmConfig.enable
	- Enables my catppuccin-sddm configuration
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/environment/sddm.nix'

## stylixConfig.enable
	- Enables stylix for system theming
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/environment/stylix.nix'

## gamingPkgs.enable
	- Enables gaming-related packages
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/software/gaming/gaming_pkgs.nix'

## steamConfig.enable
	- Enables my Steam configuration
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/software/gaming/steam.nix'

## sysPkgs.enable
	- Installs my default system packages
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/software/packages.nix'

## sysProgs.enable
	- Enables
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/software/programs.nix'

## sysServices.enable
	- Description
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/software/services.nix'

## virtConfig.enable
	- Description
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/software/virtualization.nix'

## powerProfiles.enable
	- Description
	- Type: Boolean
	- Default: false
	- Defined in 'modules/sys/hardware/powerprofiles.nix'
