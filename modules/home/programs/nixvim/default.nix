{
  env,
  config,
  pkgs,
  host,
  self,
  ...
}:
{
  programs.nixvim = {
    nixpkgs.useGlobalPackages = true;
  };
  imports = [
    ./plugins
    ./options.nix
    ./keymaps.nix
    ./autocmd.nix
  ];
}
