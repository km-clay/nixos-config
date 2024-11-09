{ host, nur, nixvim, self, inputs, username, config, home-manager, ... }: {
  imports = [
    ./gtk.nix
    ./spicetify.nix
    ./stylix.nix
    ./starship.nix
    ./userpkgs.nix
    ./zshell.nix
    ./swaync.nix
    ./hyprland.nix
    ./waybar.nix
  ];
}
