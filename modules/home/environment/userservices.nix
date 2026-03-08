{ pkgs, self, ... }:

let
  pythonWithPkgs = pkgs.python3.withPackages (p: [ p.evdev ]);
  keyboardSfxScript = "${self}/assets/scripts/keyboard_sound_thing.py";
in
{
  systemd.user = {
    timers = {
      maintenanceCheck = {
        Unit = { Description = "Timer for package maintenance check"; };
        Timer = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
    };
    services = {
      kitty-keyboard-sounds = {
        description = "Keyboard sound effects for kitty";
        wantedBy = [ "hyprland-session.target" ];
        serviceConfig = {
          ExecStart = "${pythonWithPkgs}/bin/python3 ${keyboardSfxScript}";
        };
      };
    };
  };
}
