{
  programs.nixvim = {
    plugins.vim-matchup = {
      enable = true;
      settings = {
        surround_enabled = 1;
        text_obj_enabled = 1;
        motion_enabled = 1;
        motion_cursor_end = 1;
        matchparen_deferred_hi_surround_always = true;
        matchparen_offscreen = { method = "popup"; };
        treesitter = {
          enable = true;
          include_match_words = true;
        };
      };
    };
  };
}
