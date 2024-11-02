{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./plugins
    ./options.nix
    ./keymaps.nix
    ./autocmd.nix
  ];
}
