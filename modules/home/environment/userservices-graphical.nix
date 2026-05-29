args:
let
  inherit (args) pkgs self;
  sndpath = "${self}/assets/sound";
in
{
  systemd.user = {
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
