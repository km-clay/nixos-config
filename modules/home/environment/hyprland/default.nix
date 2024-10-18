{
  inputs,
  host,
  ...
}:
{
  imports =
    [(import ./hyprland.nix)]
		++ [(import ./config.nix)];
}
