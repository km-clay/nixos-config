{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "%.snap"
            "^%.git/"
          ];
        };
        pickers = {
          find_files = {
            hidden = true;
          };
        };
      };
    };
  };
}
