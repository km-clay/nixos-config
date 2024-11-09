{ lib, config, pkgs, ... }: {
  options = {
    movOpts.programConfigs.kittyConfig.enable =
      lib.mkEnableOption "enables my kitty configuration";
  };
  config = lib.mkIf config.movOpts.programConfigs.kittyConfig.enable {
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
    };
  };
}
