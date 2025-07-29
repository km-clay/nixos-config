{
  programs.nixvim = {
    plugins = {
      cmp-snippy.enable = true;
      cmp = {
        enable = true;
        settings = {
          mapping = {
            __raw = ''
              cmp.mapping.preset.insert({
                ['<C-o>'] = cmp.mapping.close_docs(),
                ['<C-i>'] = cmp.mapping.open_docs(),
                ['<C-j>'] = cmp.mapping.scroll_docs(-4),
                ['<C-k>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-Enter>'] = function()
                  local copilot = require("copilot.suggestion")
                  cmp.abort()
                  copilot.next()
                end,
                ['<CR>'] = function(fallback)
                  if cmp.visible() then
                    cmp.confirm()
                  else
                    fallback()
                  end
                end,
                ['<Tab>'] = function(fallback)
                  local copilot = require("copilot.suggestion")
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif copilot.is_visible() then
                    cmp.abort()
                    copilot.accept()
                  else
                    fallback()
                  end
                end,
                ['<A-Tab>'] = function(fallback)
                  local copilot = require("copilot.suggestion")
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif copilot.is_visible() then
                    cmp.abort()
                    copilot.accept_word()
                  else
                    fallback()
                  end
                end,
                ['<S-Tab>'] = function(fallback)
                  local copilot = require("copilot.suggestion")
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif copilot.is_visible() then
                    cmp.abort()
                    copilot.accept_line()
                  else
                    fallback()
                  end
                end
              })
            '';
          };
          window = { completion.border = "rounded"; };
        };
      };
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          ccls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          ts_ls.enable = true;
          eslint.enable = true;
          html.enable = true;
          jsonls.enable = true;
          lua_ls.enable = true;
          marksman.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
            settings = {
              check.allTargets = false;
            };
          };
          nixd = {
            enable = true;
            settings = {
              nixd = {
                nixpkgs.expr = "import <nixpkgs> { }";
                formatting.command = "nixfmt";
              };
              options = {
                # uses Xenon config because it has every option exposed to it
                nixos.expr = ''
                  (builtins.getFlake "github:pagedMov/nixos-config").nixosConfigurations.xenon.options'';
                home.expr = ''
                  (builtins.getFlake "github:pagedMov/nixos-config").homeConfigurations.xenonHome.options'';
              };
            };
          };
          jdtls.enable = true;
          pyright.enable = true;
          sqls.enable = true;
          hls = {
            enable = true;
            installGhc = true;
          };
        };
      };
    };
  };
}
