{ ... }:

{
  programs.nixvim.plugins.rustaceanvim = {
    enable = true;
    settings = {
      server.auto_attach = true;
    };
  };
}
