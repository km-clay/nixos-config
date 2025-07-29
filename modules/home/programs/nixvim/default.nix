{ env, config, pkgs, host, self, ... }: {
  programs.nixvim.extraPackages = [
    pkgs.cargo
    pkgs.rustc
    pkgs.rustup
    pkgs.rust-analyzer
  ];
  imports = [ ./plugins ./options.nix ./keymaps.nix ./autocmd.nix ];
}
