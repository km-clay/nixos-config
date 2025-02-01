{ ... }:

{
  programs.nixvim.plugins.rustaceanvim = {
    enable = false;
    settings = {
      server.auto_attach = true;
      dap.adapter = false;
    };
  };
}
