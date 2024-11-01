{
  pkgs,
  scheme,
  ...
}: {
  programs.kitty = {
    enable = true;

    settings = {
      confirm_os_window_close = 0;
      window_padding_width = 4;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      allow_remote_control = true;
      mouse_hide_wait = 60;

      ## Tabs
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
    };

    keybindings = {
      ## Tabs
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";

      ## Unbind
      "ctrl+shift+left" = "no_op";
      "ctrl+shift+right" = "no_op";
    };

    extraConfig = ''
      background #${scheme.base00}
      foreground #${scheme.base05}
      selection_background #${scheme.base05}
      selection_foreground #${scheme.base00}
      url_color #${scheme.base04}
      cursor #${scheme.base05}
      active_border_color #${scheme.base03}
      inactive_border_color #${scheme.base01}
      active_tab_background #${scheme.base00}
      active_tab_foreground #${scheme.base05}
      inactive_tab_background #${scheme.base01}
      inactive_tab_foreground #${scheme.base04}
      tab_bar_background #${scheme.base01}

      # normal
      color0 #${scheme.base01}
      color1 #${scheme.base08}
      color2 #${scheme.base0B}
      color3 #${scheme.base0A}
      color4 #${scheme.base0D}
      color5 #${scheme.base0E}
      color6 #${scheme.base0C}
      color7 #${scheme.base05}

      # bright
      color8 #${scheme.base03}
      color9 #${scheme.base09}
      color10 #${scheme.base01}
      color11 #${scheme.base02}
      color12 #${scheme.base04}
      color13 #${scheme.base06}
      color14 #${scheme.base0F}
      color15 #${scheme.base07}
    '';
  };
}
