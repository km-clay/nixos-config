{
  inputs,
  username,
  nixpkgsConfig ? { allowUnfree = true; },
  host,
  hostDir,
  system ? "x86_64-linux",
  kind,
  extraNixosModules ? [],
  extraHomeModules ? [],
  overlay ? true
}:

let
  nixosModules = [
    ../hosts/${hostDir}/config.nix
    ../modules/sys
    inputs.stylix.nixosModules.stylix
  ] ++ extraNixosModules;
  homeModules = [
    ../hosts/${hostDir}/home.nix
    ../modules/home
    inputs.stylix.homeModules.stylix
    inputs.nixvim.homeManagerModules.nixvim
  ] ++ extraHomeModules;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = nixpkgsConfig;
    overlays = if overlay then [
      (import ../overlay/overlay.nix { inherit host; root = inputs.self; })
    ] else [];
  };
  specialArgs = {
    inherit inputs username host;
    self = inputs.self;
  };

  nixosCfg =
    if kind == "nixos" || kind == "both" then
      inputs.nixpkgs.lib.nixosSystem {
        inherit system pkgs specialArgs;
        modules = nixosModules;
      }
    else
      null;

  homeCfg =
    if kind == "home" || kind == "both" then
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs;
        modules = homeModules;
      }
    else
      null;
in
  {
    nixosConfigurations = if kind == "nixos" || kind == "both" then { ${host} = nixosCfg; } else {};
    homeConfigurations = if kind == "home" || kind == "both" then { ${host + "Home"} = homeCfg; } else {};
  }
