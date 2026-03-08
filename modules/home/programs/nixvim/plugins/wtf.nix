{
  programs.nixvim = {
    plugins.wtf = {
      enable = true;
      options = {
        context = true;
      };
    };
  };
}
