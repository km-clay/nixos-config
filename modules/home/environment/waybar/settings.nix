{
pkgs,
...
}:
# Grocery list:
# Clock
# CPU/MEM meters
# Home folder and Nix store storage tracking?
# Workspaces (per monitor would be nice)
# A separate bar for both monitors
# secondary monitor will have a vertical bar on the left side
# Can contain more info with two bars
let
  workspaces = {
      format = "{icon}";
      format-icons = {
        "1" = "一";
        "2" = "二";
        "3" = "三";
        "4" = "四";
        "5" = "五";
        "6" = "六";
      };
      persistent-workspaces = {
        "HDMI-A-1" = [ 1 2 3 ];
        "DP-1" = [ 4 5 6 ];
      };
  };

in
{
  programs.waybar.settings.mainBar = {
    layer = "bottom";
    output = "DP-1";
    position = "top";
    name = "mainBar";
    mode = "dock";

    modules-left = [
      "hyprland/workspaces"
      "cava"
    ];
    modules-center = [
      "clock"
    ];
    modules-right = [
      "custom/disk-icon"
      "memory"
      "cpu"
      "group/powerbtns"
    ];

    "hyprland/workspaces" = workspaces;

    cava = {
      framerate = 30;
      autosens = 1;
      sensitivity = 1;
      bars = 14;
      lower_cutoff_freq = 50;
      higher_cutoff_freq = 10000;
      method = "pulse";
      source = "auto";
      stereo = true;
      reverse = true;
      bar_delimiter = 0;
      monstercat = false;
      waves = false;
      noise_reduction = 0.77;
      input_delay = 2;
      format-icons  = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
    };

    "custom/disk-icon" = {
      exec = ''
      df /dev/disk/by-partlabel/disk-main-home | awk '$6 == "/home" {printf "{\"class\": \"disk-icon\", \"tooltip\": \"/home: %.1fGB / %.1fTB\", \"percentage\": \"%.0f\"}\n", $3 / 1024 / 1024, $2 / 1024 / 1024 / 1024, $5}' | jq --unbuffered --compact-output
      '';
      interval = 300;
      return-type = "json";
      rotate = 270;
      format = "{icon}";
      format-icons = [
        "󰝦" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥"
      ];
    };

    memory = {
      interval = 1;
      rotate = 270;
      format = "{icon}";
      format-icons = [
        "󰝦" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥"
      ];
      max-length = 10;
    };

    cpu = {
      interval = 1;
      rotate = 270;
      format = "{icon}";
      format-icons = [
        "󰝦" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥"
      ];
    };

    "custom/power" = {
      on-click = "shutdown now";
      tooltip = false;
      format = " ";
    };

    "custom/logout" = {
      on-click = "hyprctl dispatch exit";
      tooltip = false;
      format = "󰗽 ";
    };

    "custom/reboot" = {
      on-click = "reboot";
      tooltip = false;
      format = " ";
    };

    "group/powerbtns" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 500;
        children-class = "power-drawer";
        transition-left-to-right = false;
      };
      modules = [
        "custom/power"
        "custom/logout"
        "custom/reboot"
      ];
    };


};

# ------------------------------------------

  programs.waybar.settings.sideBar = {
    layer = "bottom";
    output = "HDMI-A-1";
    position = "right";
    name = "sideBar";
    mode = "dock";

    modules-left = [
      "hyprland/workspaces"
    ];
    modules-center = [
      "tray"
    ];
    modules-right = [
      "pulseaudio/slider"
      "pulseaudio"
      "network"
    ];

    "hyprland/workspaces" = workspaces;

    "pulseaudio/slider" = {
      orientation = "vertical";
    };

    pulseaudio = {
      format = "{icon}";
      format-muted = " ";
      format-icons = {
        default = [
          " "
          " "
        ];
      };
      on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      on-click-right = "hyprctl dispatch exec '[float;size 40% 55%] pavucontrol'";
    };

    network = {
      interval = 30;
      format-wifi = "󰖩 ";
      tooltip-format-wifi = "{essid} ({signalStrength}%)";
      format-ethernet = " ";
      tooltip-format-ethernet = "{ifname}";
      format-disconnected = "󰖪 ";
      tooltip-format-disconnected = "Disconnected";
      on-click = "hyprctl dispatch exec '[float;size 40% 55%] kitty nmtui'";
    };
  };
}
