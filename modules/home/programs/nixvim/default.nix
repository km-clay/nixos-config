{ env, config, pkgs, host, self, ... }: {
  programs.nixvim = {
    nixpkgs.useGlobalPackages = true;
    extraPackages = [
      pkgs.cargo
      pkgs.rustc
      pkgs.clippy
      pkgs.rustup
      pkgs.rust-analyzer
      pkgs.nerd-fonts.envy-code-r
    ];
  };
  imports = [ ./plugins ./options.nix ./keymaps.nix ./autocmd.nix ];
}
