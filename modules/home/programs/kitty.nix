args:
let
  inherit (args) lib pkgs;
in
{
  programs.kitty = {
    enable = true;
    font = {
      package = lib.mkForce pkgs.maple-mono.truetype-autohint;
      name = lib.mkForce "Maple Mono";
      size = lib.mkForce 19;
    };

    settings = {
      confirm_os_window_close = 0;
      background_opacity = lib.mkForce 0.65;
      dynamic_background_opacity = true;
      window_padding_width = 4;
      scrollback_lines = 10000;
      enable_audio_bell = true;
      allow_remote_control = true;
      mouse_hide_wait = 60;
      command_on_bell = "${pkgs.myScripts.playshellsound}/bin/playshellsound bell.wav";

      ## Tabs
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      tab_bar_style = "powerline";
      tab_bar_edge = "top";
      tab_powerline_style = "round";
    };

    keybindings = {
      "ctrl+shift+right"     = "no_op";
      "ctrl+shift+left"      = "no_op";
      "ctrl+shift+l"         = "next_tab";
      "ctrl+shift+h"         = "previous_tab";
      "ctrl+shift+j"         = "scroll_end";
      "ctrl+shift+k"         = "scroll_home";
      "ctrl+shift+equal"     = "change_font_size all +2.0";
      "ctrl+shift+minus"     = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";
    };
  };
}
