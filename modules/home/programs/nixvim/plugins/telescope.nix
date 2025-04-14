{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "%.snap"
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
