_:
{
  movOpts.homeConfig.enableProfiles = [ "cli" "graphical" ];
  movOpts.envConfig.hyprlandConfig = {
    monitorNames = [
      "DP-1"
      "HDMI-A-1"
    ];
    workspaceLayout = "dualmonitor";
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
