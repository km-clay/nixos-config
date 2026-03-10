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
        action = "zA";
        key = "<CR>";
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
        mode = [
          "n"
          "t"
        ];
      }
      {
        action = "<cmd>lua require('treesj').toggle()<CR>";
        key = "<space>j";
        mode = [ "n" ];
      }
      {
        action = "<C-\\><C-n>";
        key = "<C-e>";
        mode = [ "t" ];
      }
      {
        action = ''"+y'';
        key = "<space>y";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action = ''"+p'';
        key = "<space>p";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ "function() require('opencode').prompt('test', {submit=true}) end";
        key = "<space>at";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ "function() require('opencode').select() end";
        key = "<space>as";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ "function() require('opencode').prompt('document', {submit=true}) end";
        key = "<space>ad";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ "function() require('opencode').prompt('review', {submit=true}) end";
        key = "<space>ar";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ "function() require('opencode').prompt('fix', {submit=true}) end";
        key = "<space>af";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() require('opencode').ask("@this ", {submit=true}) end'';
        key = "<space>aa";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() require('opencode').explain("@this ") end'';
        key = "<space>ae";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() require('opencode').command("session.half.page.up") end'';
        key = "<C-S-u>";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() require('opencode').command("session.half.page.down") end'';
        key = "<C-S-d>";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() require('opencode').command("prompt.clear") end'';
        key = "<C-c>";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() require('opencode').operator("@this ") end'';
        key = "go";
        mode = [
          "n"
          "x"
        ];
      }
      {
        action.__raw = /* lua */ ''function() return require('opencode').operator("@this ") .. "_" end'';
        key = "goo";
        mode = [ "n" ];
      }
      {
        action = "<cmd>lua require('opencode').toggle()<CR>";
        key = "<C-.>";
        mode = [
          "n"
          "t"
        ];
      }
      {
        action = "<cmd>lua require('opencode').select()<CR>";
        key = "<C-n>";
        mode = [
          "n"
          "x"
        ];
      }
    ];
  };
}
