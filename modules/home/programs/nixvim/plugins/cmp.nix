{
  programs.nixvim = {
    plugins.cmp = {
      autoEnableSources = true;
      settings.sources =
        [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
    };
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-nvim-lsp-document-symbol.enable = true;
    plugins.cmp-nvim-lsp-signature-help.enable = true;
  };
}
