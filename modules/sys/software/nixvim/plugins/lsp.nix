{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        ccls.enable = true;
        clangd.enable = true;
        cmake.enable = true;
        html.enable = true;
        jsonls.enable = true;
        lua_ls.enable = true;
        marksman.enable = true;
        nil_ls.enable = true;
        pyright.enable = true;
        sqls.enable = true;
        hls = {
          enable = true;
          installGhc = true;
        };
      };
    };
  };
}
