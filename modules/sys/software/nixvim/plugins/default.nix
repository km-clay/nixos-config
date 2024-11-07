{ host, self, ... }:

{
  imports = [
    ./alpha.nix
    ./haskell.nix
    ./vim-matchup.nix
    ./coq.nix
    ./barbar.nix
    ./cmp.nix
    ( import ./lsp.nix { inherit host self; })
    ./lualine.nix
    ./plugins.nix
    ./nvim-tree.nix
    ./telescope.nix
    ./extra_plugins.nix
  ];
}
