{ env, config, pkgs, host, self, ... }: {
  imports = [ ./plugins ./options.nix ./keymaps.nix ./autocmd.nix ];
}
