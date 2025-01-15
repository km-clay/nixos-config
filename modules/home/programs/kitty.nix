{ lib, config, pkgs, ... }: {
  options = {
    movOpts.programConfigs.kittyConfig.enable =
      lib.mkEnableOption "enables my kitty configuration";
  };
  config = lib.mkIf config.movOpts.programConfigs.kittyConfig.enable {
    programs.kitty = {
      enable = true;
      font = {
        package = lib.mkForce pkgs.fira-code;
        name = lib.mkForce "Fira Code";
        size = lib.mkForce 20;
      };

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
        tab_bar_edge = "top";
        tab_powerline_style = "round";
      };

      keybindings = {
        "ctrl+shift+h" = "next_tab";
        "ctrl+shift+l" = "previous_tab";
        "ctrl+shift+j" = "scroll_end";
        "ctrl+shift+k" = "scroll_home";
      };
    };
  };
}
