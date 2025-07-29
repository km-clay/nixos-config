{
  programs.nixvim = {
    keymaps = [
      {
        action = "<cmd>Telescope find_files<CR>"; # select entire document
        key = "<F3>";
        mode = "n";
      }
      {
        action = "<cmd>UndotreeToggle<CR>"; # select entire document
        key = "!t";
        mode = "n";
      }
      {
        action = "gg<S-V>G"; # select entire document
        key = "!a";
        mode = "n";
      }
      {
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        key = "!ca";
        mode = "n";
      }
      {
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
        key = "!fmt";
        mode = "n";
      }
      {
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        key = "!df";
        mode = "n";
      }
      {
        action = "<C-W>W";
        key = "<S-Tab>";
        mode = "n";
      }
      {
        action = "<C-w>w";
        key = "<Tab>";
        mode = "n";
      }
      {
        action = "<cmd>FloatermToggle def_term<CR>";
        key = "<F2>";
        mode = [ "n" "t" ];
      }
      {
        action = "<cmd>COQnow<CR>";
        key = "!cq";
        mode = "n";
      }
    ];
  };
}
