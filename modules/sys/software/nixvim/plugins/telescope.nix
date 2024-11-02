{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      settings = {
        pickers = {
          find_files = {
            hidden = true;
          };
        };
      };
    };
  };
}
