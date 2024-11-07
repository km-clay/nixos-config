{ host, ... }:
let
  flakePath = builtins.getEnv "FLAKEPATH";
in
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
          nixd = {
            enable = true;
            settings = {
              nixd = {
                nixpkgs.expr = "import <nixpkgs> { }";
                formatting.command = "nixfmt";
                options = {
                  nixos.expr = "(builtins.getFlake \"github:pagedMov/nixos-config\").nixosConfigurations.xenon.options";
                };
              };
            };
          };
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
