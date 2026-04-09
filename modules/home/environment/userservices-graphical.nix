args:
let
  inherit (args) pkgs self;
  keyboardSfxScript = "${self}/assets/scripts/keyboard_sound_thing.py";
in
{
  systemd.user = {
    services = {
      awww-daemon = {
        Unit.Description = "Daemon for awww (sway wayland wallpaper manager)";
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
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
