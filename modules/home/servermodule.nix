{ inputs, nixpkgs, config, self, username, host, lib, ... }: {
  imports = [
    ./environment/starship.nix
    ./environment/userpkgs.nix
    ./environment/stylixhome.nix
    ./environment/zsh
    ./programs/nixvim
    ./programs/autojump.nix
    ./programs/bat.nix
    ./programs/kitty.nix
    ./programs/btop.nix
    ./programs/eza.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/yazi.nix
    ./files.nix
  ];
}
