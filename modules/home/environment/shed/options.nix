{ pkgs, ... }:

{
  programs.shed = {
    enable = true;

    shopts = {
      line = {
        viewport_height = "50%";
        scroll_offset = 2;
      };
      core = {
        autocd = true;
        auto_hist = true;
        max_hist = -1;
      };
      prompt = {
        screensaver_cmd = "${pkgs.cbonsai}/bin/cbonsai -l -t 10 -w 600";
        screensaver_idle_time = 600; # 10 minutes
        completion_ignore_case = true;
        line_numbers = true;
      };
    };
  };
}
