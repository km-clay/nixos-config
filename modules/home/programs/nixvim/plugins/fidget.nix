{
  programs.nixvim.plugins.fidget = {
    enable = true;
    settings = {
      notification = {
        overrideVimNotify = true;
        window = { border = "rounded"; };
      };
    };
  };
}
