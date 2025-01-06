{ host, self, pkgs, env, ... }:

{
  imports = [
    ./alpha.nix
    ./haskell.nix
    ./vim-matchup.nix
    # ./coq.nix
    ./barbar.nix
    ./scrollview.nix
    ./cmp.nix
    ./lsp.nix
    ./rustaceanvim.nix
    ./fidget.nix
    # ./lualine.nix
    ./airline.nix
    ./nvim-lightbulb.nix
    ./neocord.nix
    ./plugins.nix
    ./nvim-tree.nix
    ./telescope.nix
    ./indent-blankline.nix
    ./gitsigns.nix
    ./extra_plugins.nix
  ];
}
