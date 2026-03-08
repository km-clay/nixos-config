{ ... }:

{
  programs.nixvim.plugins.rustaceanvim = {
    enable = false;
    settings = {
      server = {
        auto_attach = true;
        default_settings = {
          cfgOverride.test = true;
          checkOnSave.command = "clippy";
        };
      };
      dap.adapter = false;
    };
  };
}
