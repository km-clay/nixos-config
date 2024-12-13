{
  programs.nixvim = {
    plugins = {
      dap = {
        enable = true;
        extensions.dap-ui.enable = true;
      };
      nix.enable = true;
      endwise.enable = true;
      firenvim.enable = true;
      helpview.enable = true;
      floaterm.enable = true;
      fugitive.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      lastplace.enable = true;
      markdown-preview.enable = true;
      marks.enable = true;
      nvim-surround.enable = true;
      rainbow-delimiters.enable = true;
      render-markdown.enable = true;
      treesitter.enable = true;
      trim.enable = true;
      trouble.enable = true;
      web-devicons.enable = true;
    };
  };
}
