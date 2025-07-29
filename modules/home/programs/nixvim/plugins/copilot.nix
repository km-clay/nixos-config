{
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    settings = {
      suggestion = {
        auto_trigger = false;
      };
    };
  };
}
