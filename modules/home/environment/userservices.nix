{ pkgs, self, ... }:

let
  keyboardSfxScript = "${self}/assets/scripts/keyboard_sound_thing.py";
in
{
  systemd.user = {
    services = {
      swww-daemon = {
        Unit.Description = "Daemon for swww (sway wayland wallpaper manager)";
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${pkgs.swww}/bin/swww-daemon";
        };
      };
      kitty-keyboard-sounds = {
        Unit.Description = "Keyboard sound effects for kitty";
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${pkgs.myPython}/bin/python3 ${keyboardSfxScript}";
        };
      };
    };
  };
}
