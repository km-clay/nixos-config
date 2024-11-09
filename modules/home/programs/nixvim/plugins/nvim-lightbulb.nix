{
  programs.nixvim.plugins.nvim-lightbulb = {
    enable = true;
    settings = {
      virtual_text = { enable = true; };
      autocmd.enabled = true;
    };
  };
}
