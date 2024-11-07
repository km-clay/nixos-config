{
  programs.nixvim = {
    keymaps = [
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
        action = "<cmd>FloatermToggle shadeterm<CR>";
        key = "<F2>";
        mode = "n";
      }
      {
        action = "<cmd>NvimTreeToggle<CR>";
        key = "<F3>";
        mode = "n";
      }
      {
        action = "<cmd>FloatermToggle shadeterm<CR>";
        key = "<F2>";
        mode = "t";
      }
      {
        action = "<cmd>COQnow<CR>";
        key = "!cq";
        mode = "n";
      }
    ];
  };
}
