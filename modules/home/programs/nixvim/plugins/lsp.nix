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
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<CR>'] = function(fallback)
                    if cmp.visible() then
                      cmp.confirm()
                    else
                      fallback()
                    end
                  end,  -- Added a comma here
                  ['<Tab>'] = function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    else
                      fallback()
                    end
                  end,  -- Added a comma here
                  ['<S-Tab>'] = function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    else
                      fallback()
                    end
                  end  -- No comma needed for the last item
                })
              '';
            };
            window = {
              completion.border = "rounded";
            };
          };
        };
        lsp = {
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
                };
                options = {
                  # uses Xenon config because it has every option exposed to it
                  nixos.expr = "(builtins.getFlake \"github:pagedMov/nixos-config\").nixosConfigurations.xenon.options";
                  home.expr = "(builtins.getFlake \"github:pagedMov/nixos-config\").homeConfigurations.xenonHome.options";
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
    };
  }
