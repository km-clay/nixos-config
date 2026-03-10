{
  self,
  pkgs,
  lib,
  ...
}:

let
  paperdScript = import ./paperd_script.nix { inherit pkgs; };
in
{
  home.file.".config/paperd/config.toml".text = ''
    wallpaper_dir = "${self}/assets/wallpapers/selective_color"
    interval = 1800

    [transition]
    type = "fade"
    duration = 3
    fps = 60
  '';
  systemd.user.services = {
    paperd = {
      Unit = {
        Description = "Paperd Wallpaper Daemon";
        After = [ "swww-daemon.service" ];
        Requires = [ "swww-daemon.service" ];
      };
      Install.WantedBy = [ "hyprland-session.target" ];
      Service = {
        Environment = "PYTHONUNBUFFERED=1";
        ExecStart = "${pkgs.myPython}/bin/python3 ${paperdScript}";
      };
    };
  };
}
