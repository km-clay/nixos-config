{
  programs.nixvim = {
    plugins.barbar = {
      enable = false;
      settings = {
        auto_hide = 1;
      };
    };
  };
}
