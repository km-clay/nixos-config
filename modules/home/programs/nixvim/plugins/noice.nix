{
  programs.nixvim = {
    plugins.noice = {
      enable = true;
      settings = {
        views = {
          popupmenu = {
            relative = "cursor";
            position = {
              row = -2;
              col = -2;
            };
            size = {
              width = 60;
              height = "auto";
            };
          };
          cmdline_popup = {
            relative = "cursor";
            position = {
              row = 0;
              col = -2;
            };
            size = {
              width = 60;
              height = "auto";
            };
          };
        };
      };
    };
  };
}
