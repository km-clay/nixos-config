{
  programs.nixvim = {
    plugins.otter = {
      enable = false;
      settings = {
        handle_leading_whitespace = true;
      };
    };
  };
}
