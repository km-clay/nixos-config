{ pkgs, self, ... }:

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
      loginSound = {
        Unit= {
          Description = "Plays a sound on login";
          After = [ "graphical-session.target" ];
          WantedBy = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.alsa-utils}/bin/aplay -qN ${self}/assets/sound/login.wav";
          Type = "simple";
        };
      };
      maintenanceCheck = {
        Unit = {
          Description = "Check for updates in my maintained packages";
        };

        Service = {
          ExecStart = "${pkgs.nix}/bin/nix-shell -p python3Packages.requests --run '${pkgs.python311}/bin/python ${pkgs.myScripts.check_updates}/bin/checkupdates.py'";
          Type = "simple";
        };
      };
    };
  };
}
