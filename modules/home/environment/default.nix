{
  host,
  nur,
	nixvim,
  self,
  inputs,
  username,
  config,
  home-manager,
  ...
}: {
  imports =
    [(import ./gtk.nix)]
    ++ [(import ./spicetify.nix)]
    ++ [(import ./stylix.nix)]
    ++ [(import ./starship.nix)]
    ++ [(import ./userpkgs.nix)]
    ++ [(import ./zshell.nix)]
    ++ [(import ./swaync.nix)]
    ++ [(import ./waybar)]
    ++ [(import ./hyprland)];
}
