{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
    };
    plugins.treesj = {
      enable = true;
      settings = {
        use_default_keymaps = false;
      };
    };
  };
}
