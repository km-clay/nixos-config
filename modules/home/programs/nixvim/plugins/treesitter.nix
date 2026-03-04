{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      folding = {
        enable = true;
      };
      indent = {
        enable = true;
      };
      highlight = {
        enable = true;
      };
    };
  };
}
