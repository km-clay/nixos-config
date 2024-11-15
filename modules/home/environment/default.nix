{ host, nur, nixvim, self, inputs, username, config, home-manager, ... }: {
  imports = [
    ./gtk.nix
    ./spicetify.nix
    ./stylixhome.nix
    ./userservices.nix
    ./starship.nix
    ./userpkgs.nix
    ./zsh
    ./swaync.nix
    ./hyprland.nix
    ./waybar.nix
  ];
}
