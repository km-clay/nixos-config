{...}: 
{
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "left";
    mod = "dock";
    margin-left = 4;
    margin-right = 0;
    margin-top = 4;
    margin-bottom = 4;
    exclusive = true;
    passthrough = false;
    "gtk-layer-shell" = true;
    reload_style_on_change = true;

    modules-left = [
      "custom/spacer"
      "hyprland/workspaces"
      "custom/spacer"
    ];

    modules-right = [
      "group/expand"
      "group/expand-3"
      "network"
      "clock"
      "upower"
      "custom/notification"
    ];

    "custom/led" = {
      format = "<span color='#AFAFAF'>󰍿</span><span color='#AFAFAF'> </span>";
      format-alt = "󰍿<span color='#83A1F6'> </span>";
      on-click = "~/mouse.sh";
      rotate = 90;
      tooltip = false;
    };

		"group/expand-3" = {
      orientation = "vertical";
      drawer = {
        "transition-duration" = 600;
        "children-class" = "not-power";
        "transition-to-left" = false;
        "click-to-reveal" = false;
      };
      modules = [
        "pulseaudio"
        "pulseaudio/slider"
      ];
    };

		clock = {
      format = "{:%I\n%M}";
      interval = 1;
      rotate = 0;
      on-click = "/usr/local/bin/ags -t ActivityCenter";
      tooltip-format = "<tt>{calendar}</tt>";

      calendar = {
        mode = "month";
        "mode-mon-col" = 3;
        "on-scroll" = 1;
        "on-click-right" = "mode";
        format = {
          months = "<span color='#ffead3'><b>{}</b></span>";
          weekdays = "<span color='#ffcc66'><b>{}</b></span>";
          today = "<span color='#ff6699'><b>{}</b></span>";
        };
      };

      actions = {
        "on-click-right" = "mode";
        "on-click-forward" = "tz_up";
        "on-click-backward" = "tz_down";
        "on-scroll-up" = "shift_up";
        "on-scroll-down" = "shift_down";
      };
    };

    upower = {
      icon-size = 20;
      format = "";
      on-click = "/home/anik/battery.sh";
      tooltip = true;
      rotate = 0;
      tooltip-spacing = 20;
      on-click-right = "pkill waybar & hyprctl dispatch exec waybar";
    };

    "upower#headset" = {
      format = " {percentage}";
      "native-path" = "/org/freedesktop/UPower/devices/headset_dev_A6_98_9A_0D_D3_49";
      "show-icon" = false;
      tooltip = false;
    };

    "group/expand-4" = {
      orientation = "horizontal";
      drawer = {
        "transition-duration" = 600;
        "children-class" = "not-power";
        "transition-to-left" = true;
        "click-to-reveal" = true;
      };
      modules = ["upower" "upower/headset"];
    };

    network = {
      tooltip = true;
      format-wifi = "{icon} ";
      format-icons = ["󰤟" "󰤢" "󰤥"];
      rotate = 0;
      format-ethernet = "󰈀 ";
      tooltip-format = ''
        Network: <big><b>{essid}</b></big>\n
        Signal strength: <b>{signaldBm}dBm ({signalStrength}%)</b>\n
        Frequency: <b>{frequency}MHz</b>\n
        Interface: <b>{ifname}</b>\n
        IP: <b>{ipaddr}/{cidr}</b>\n
        Gateway: <b>{gwaddr}</b>\n
        Netmask: <b>{netmask}</b>
      '';
      format-linked = "󰈀 {ifname} (No IP)";
      format-disconnected = "";
      tooltip-format-disconnected = "Disconnected";
      on-click = "/usr/local/bin/ags -t ControlPanel";
      interval = 2;
    };

    "custom/smallspacer" = {
      format = " ";
      rotate = 0;
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
      format = "{icon}";
      rotate = 270;
      format-icons = [
        "󰝦" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥"
      ];
    };

    "mpris" = {
      format = "󰝚 {player_icon}";
      rotate = 90;
      "format-paused" = "<span color='#2d2d2e'>󰝚 {status_icon}</span>";
      "max-length" = 6;
      "player-icons" = {
        default = "󰏤";
        mpv = "󰝚";
      };
      "status-icons" = {
        paused = "󰐊";
      };
    };

    tray = {
      "icon-size" = 16;
      rotate = 0;
      spacing = 3;
    };

    "group/expand" = {
      orientation = "vertical";
      drawer = {
        "transition-duration" = 600;
        "children-class" = "not-power";
        "transition-to-left" = true;
      };
      modules = ["custom/menu" "custom/spacer" "tray"];
    };

    "custom/menu" = {
      format = "󰅃";
      rotate = 0;
    };

    "custom/notification" = {
      tooltip = false;
      rotate = 0;
      format = "{icon}";
      format-icons = {
        notification = "󱅫";
        none = "󰂚";
        "dnd-notification" = "󱅫";
        "dnd-none" = "󰂚";
        "inhibited-notification" = "󱅫";
        "inhibited-none" = "󰂚";
        "dnd-inhibited-notification" = "󱅫";
        "dnd-inhibited-none" = "󰂚";
      };
      "return-type" = "json";
      "exec-if" = "which swaync-client";
      exec = "swaync-client -swb";
      "on-click-right" = "swaync-client -d -sw";
      "on-click" = "swaync-client -t -sw";
      escape = true;
    };

    "hyprland/window" = {
      format = "<span  weight='bold' >{class}</span>";
      "on-click-right" = "pkill waybar & hyprctl dispatch exec waybar";
      rotate = 90;
      "max-length" = 120;
      icon = false;
      "icon-size" = 13;
    };

    "custom/power" = {
      format = "@{}";
      rotate = 0;
      "on-click" = "ags -t ControlPanel";
      "on-click-right" = "pkill ags";
      tooltip = true;
    };

    "custom/spacer" = {
      format = "|";
      rotate = 90;
    };

    "hyprland/workspaces" = {
      format = "{icon}";
      "format-icons" = {
        default = "";
        active = "";
      };
    };

    "wlr/workspaces" = {
      "persistent-workspaces" = {
        "1" = ["HDMI-A-1"];
        "2" = ["HDMI-A-1"];
        "3" = ["HDMI-A-1"];
        "4" = ["DP-1"];
        "5" = ["DP-1"];
        "6" = ["DP-1"];
      };
    };
		pulseaudio = {
      format = "{icon}";
      rotate = 0;
      format-muted = "婢";
      tooltip-format = "{icon} {desc} // {volume}%";
      scroll-step = 5;

      format-icons = {
        headphone = " ";
        "hands-free" = " ";
        headset = " ";
        phone = " ";
        portable = " ";
        car = " ";
        default = ["" " " " "];
      };
    };
		"pulseaudio/slider" = {
      min = 5;
      max = 100;
      rotate = 0;
      device = "pulseaudio";
      scroll-step = 1;
      orientation = "vertical";
    };

    cava = {
      "cava_config" = "~/.config/cava/config";
      framerate = 60;
      autosens = 1;
      bars = 14;
      "lower_cutoff_freq" = 50;
      "higher_cutoff_freq" = 10000;
      method = "pulse";
      source = "auto";
      stereo = true;
      reverse = false;
      "bar_delimiter" = 0;
      monstercat = false;
      waves = false;
      "noise_reduction" = 0.77;
      "input_delay" = 2;
      "format-icons" = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
      actions = {
        "on-click-right" = "mode";
      };
    };
  };
}

