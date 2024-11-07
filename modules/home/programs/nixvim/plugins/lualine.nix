{
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          icons_enabled = true;
          theme = "auto";
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
          always_divide_middle = true;
          globalstatus = false;
          refresh = {
            statusline = 1000;
            tabline = 1000;
            winbar = 1000;
          };
        };
        sections = {
          lualine_a = ["mode"];
          lualine_b = ["buffers"];
          lualine_c = [""];
          lualine_x = ["searchcount" "fileformat" "filetype"];
          lualine_y = ["branch" "diff" "diagnostics"];
          lualine_z = ["location"];
        };
        inactive_sections = {
          lualine_a = [];
          lualine_b = [];
          lualine_c = ["filename"];
          lualine_x = ["location"];
          lualine_y = [];
          lualine_z = [];
        };
      };
    };
  };
}
