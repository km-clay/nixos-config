{
  programs.nixvim.plugins.fidget = {
    enable = false;
    settings = {
      notification = {
        overrideVimNotify = true;
        window = {
          border = "rounded";
        };
      };
    };
  };
}
