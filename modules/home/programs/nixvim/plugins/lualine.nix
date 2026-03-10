let
  colors = {
    blue = "#80a0ff";
    cyan = "#79dac8";
    black = "#080808";
    white = "#c6c6c6";
    red = "#ff5189";
    violet = "#d183e8";
    grey = "#303030";
    bg_grey = "#202020";
  };
  bubbles_theme = {
    normal = {
      a = {
        fg = colors.black;
        bg = colors.violet;
        gui = "bold";
      };
      b = {
        fg = colors.white;
        bg = colors.grey;
      };
      c = {
        fg = colors.white;
        bg = colors.bg_grey;
      };
    };

    insert = {
      a = {
        fg = colors.black;
        bg = colors.blue;
      };
    };
    visual = {
      a = {
        fg = colors.black;
        bg = colors.cyan;
      };
    };
    replace = {
      a = {
        fg = colors.black;
        bg = colors.red;
      };
    };
    inactive = {
      a = {
        fg = colors.white;
        bg = colors.grey;
      };
      b = {
        fg = colors.white;
        bg = colors.black;
      };
      c = {
        fg = colors.white;
      };
      z = {
        fg = colors.white;
        bg = colors.grey;
      };
    };
  };
in
{
  programs.nixvim = {
    plugins.lualine = {
      enable = false;
      settings = {
        options = {
          icons_enabled = true;
          theme = bubbles_theme;
          component_separators = {
            left = "|";
            right = "|";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_a.__raw = "{ { 'mode', separator = { left = '' }, right_padding = 2 } }";
          lualine_b.__raw = "{ 'filename', 'branch' }";
          lualine_c.__raw = "{}";
          lualine_x.__raw = "{}";
          lualine_y.__raw = "{ 'filetype', 'progress' }";
          lualine_z.__raw = "{ { 'location', separator = { right = '' }, left_padding = 2 } }";
        };
        inactive_sections = {
          lualine_a.__raw = "{ { 'mode', separator = { left = '' }, right_padding = 2 } }";
          lualine_b.__raw = "{ 'filename', 'branch' }";
          lualine_c.__raw = "{}";
          lualine_x.__raw = "{}";
          lualine_y.__raw = "{ 'filetype', 'progress' }";
          lualine_z.__raw = "{ { 'location', separator = { right = '' }, left_padding = 2 } }";
        };
      };
    };
  };
}
