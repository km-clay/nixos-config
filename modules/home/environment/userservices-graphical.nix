args:
let
  inherit (args) pkgs self;
  sndpath = "${self}/assets/sound";
in
{
  systemd.user = {
    timers = {
      gh-notify = {
        Unit = {
          Description = "GitHub notification poll timer";
          PartOf = [ "hyprland-session.target" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];
        Timer = {
          OnBootSec = "30";
          OnUnitActiveSec = "60";
        };
      };
    };
    services = {
      awww-daemon = {
        Unit = {
          Description = "Daemon for awww (sway wayland wallpaper manager)";
          PartOf = [ "hyprland-session.target" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
        };
      };
      set-wallpaper = {
        Unit = {
          Description = "Set static wallpaper via awww";
          After = [ "awww-daemon.service" ];
          Requires = [ "awww-daemon.service" ];
          X-RestartIfChanged = false;
        };
        Install.WantedBy = [ "hyprland-session.target" ];

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.awww}/bin/awww img ${self}/assets/wallpapers/sleeping-blackmetal.png";
        };
      };
      ptt-daemon = {
        Unit = {
          Description = "Push-to-talk manager";
          PartOf = [ "hyprland-session.target" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.myScripts.ptt}/bin/ptt-daemon";
        };
      };
      gh-notify = {
        Unit = {
          Description = "GitHub notification checker";
          PartOf = [ "hyprland-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];

        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.myScripts.gh-notify}/bin/gh-notify";
        };

      };
      login-sound = {
        Unit = {
          Description = "Login sound";
          After = [ "graphical-session.target" "pipewire.service" "pipewire-pulse.service" ];
          X-RestartIfChanged = false;
        };
        Install.WantedBy = [ "graphical-session.target" ];

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.pipewire}/bin/pw-play ${sndpath}/login.wav";
        };
      };
    };
  };
}
