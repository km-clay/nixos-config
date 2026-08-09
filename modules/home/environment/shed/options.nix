{ pkgs, ... }:

{
  programs.shed = {
    enable = true;

    shopts = {
      line = {
        viewport_height = "100%";
        scroll_offset = 2;
        line_numbers = true;
      };
      core = {
        autocd = true;
        compact_errors = true;
      };
      history = {
        auto_save = true;
        max_entries = -1;
        ignore_space = true;
        ignore_dupes = true;
      };
      set = {
        vi = true;
      };
      prompt = {
        idle_timeout = 10; # 10 seconds
        completion_ignore_case = true;
        expand_aliases = false;
        complete_style = "fuzzy";
        leader = "<Space>";
      };
      highlight = {
        operator = "bold magenta";
      };
      statline = {
        right_string = "\\@stat_line_right";
        middle_string = "\\e[39;2m$EDITOR_FILE\\e[22m";
        left_string = "\\@stat_line_left";
      };
    };
  };
}
