{ scheme, config, ... }:

{
  programs.nixvim = {
		colorschemes.base16 = {
			enable = true;
    #colorscheme = {
		  #	base00 = "#${scheme.base00}";
		  #	base01 = "#${scheme.base01}";
		  #	base02 = "#${scheme.base02}";
		  #	base03 = "#${scheme.base03}";
		  #	base04 = "#${scheme.base04}";
		  #	base05 = "#${scheme.base05}";
		  #	base06 = "#${scheme.base06}";
		  #	base07 = "#${scheme.base07}";
		  #	base08 = "#${scheme.base08}";
		  #	base09 = "#${scheme.base09}";
		  #	base0A = "#${scheme.base0A}";
		  #	base0B = "#${scheme.base0B}";
		  #	base0C = "#${scheme.base0C}";
		  #	base0D = "#${scheme.base0D}";
		  #	base0E = "#${scheme.base0E}";
		  #	base0F = "#${scheme.base0F}";
		  #};
		};
    enable = true;
    diagnostics.signs = false;
    extraConfigLua = ''
      if vim.g.started_by_firenvim == true then
      	vim.o.laststatus = 0
      end
      if vim.g.neovide then
      	vim.g.neovide_refresh_rate = 144
      	vim.g.neovide_cursor_vfx_mode = "sonicboom"
      	vim.g.neovide_cursor_animate_in_insert_mode = false
      end

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.hlsearch = true
      vim.opt.incsearch = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.termguicolors = true
      vim.opt.ruler = true
      vim.opt.scrolloff = 6
      vim.opt.undofile = true
      vim.opt.foldmethod = "manual"
      vim.opt.wrap = true
      vim.opt.linebreak = true
      vim.opt.textwidth = 0
      vim.opt.breakat = " \t!@*-+;:,./?"

      vim.g.mapleader = "!"
    '';
  };
}
