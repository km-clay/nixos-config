{
  programs.nixvim = {
    keymaps = [
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
