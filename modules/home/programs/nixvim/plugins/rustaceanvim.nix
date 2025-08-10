{ ... }:

{
  programs.nixvim.plugins.rustaceanvim = {
    enable = false;
    settings = {
      server = {
        auto_attach = true;
        default_settings = {
          checkOnSave.command = "clippy";
        };
      };
      dap.adapter = false;
    };
  };
}
