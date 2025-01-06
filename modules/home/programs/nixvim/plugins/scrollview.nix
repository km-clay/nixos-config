{
  programs.nixvim = {
    plugins.scrollview = {
      enable = true;
      settings.diagnostics_error_symbol = "■";
      settings.diagnostics_warn_symbol = "■";
      settings.diagnostics_hint_symbol = "■";
      settings.diagnostics_info_symbol = "■";
      settings.character = "│";
    };
  };
}
