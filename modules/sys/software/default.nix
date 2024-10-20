
{
  inputs,
  nixpkgs,
  config,
  self,
  username,
  host,
  ...
}:  
let
	desktop_modules = if (host == "oganesson") then
		[(import ./virtualization.nix)] ++ [(import ./gaming)]
		else [];
in
{
  imports = 
	[(import ./packages.nix)]
	++ [(import ./programs.nix)]
	++ [(import ./services.nix)]
	++ [(import ./nixvim)]
	++ desktop_modules;
}

