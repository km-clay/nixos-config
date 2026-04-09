{ pkgs, ... }:

{
  programs.shed = {
    enable = true;

    shopts = {
      line = {
        viewport_height = "50%";
        scroll_offset = 2;
        line_numbers = true;
      };
      core = {
        autocd = true;
        auto_hist = true;
        max_hist = -1;
      };
      set = {
        vi = true;
      };
      prompt = {
        screensaver_cmd = "${pkgs.whoa}/bin/whoa";
        screensaver_idle_time = 600; # 10 minutes
        completion_ignore_case = true;
      };
    };
  };
}
