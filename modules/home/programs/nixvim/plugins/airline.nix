{
  programs.nixvim = {
    plugins.airline = {
      enable = false;
      settings = {
        left_sep = "";
        right_sep = "";
        powerline_fonts = 1;
        theme = "dark";
        section_x = "";
        section_y = "";
        skip_empty_sections = 1;
      };
    };
  };
}
