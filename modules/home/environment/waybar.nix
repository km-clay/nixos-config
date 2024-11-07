{pkgs, host, lib, config, ...}:

let
  desktop = host == "oganesson";
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
    persistent-workspaces =
      if desktop
      then {
        "HDMI-A-1" = [1 2 3];
        "DP-1" = [4 5 6];
      }
      else {
        "eDP-1" = [1 2 3 4];
      };
  };

  scheme = config.lib.stylix.colors;
  bg = {
    darkester = scheme.base00;
    darkest = scheme.base01;
    darker = scheme.base02;
    dark = scheme.base03;
  };
  fg = {
    lightester = scheme.base07;
    lightest = scheme.base06;
    lighter = scheme.base05;
    light = scheme.base04;
  };
  colors = {
    color0 = scheme.base08;
    color1 = scheme.base09;
    color2 = scheme.base0A;
    color3 = scheme.base0B;
    color4 = scheme.base0C;
    color5 = scheme.base0D;
    color6 = scheme.base0E;
    color7 = scheme.base0F;
  };
  monitors =
    if desktop
    then [
      "DP-1"
      "HDMI-A-1"
    ]
    else [
      "eDP-1"
    ];
in {
  options = {
    movOpts.waybarConfig.enable = lib.mkEnableOption "enables my waybar configuration";
  };
  config = {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oa: {
          mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
        });
      settings = {
        mainBar = {
          layer = "bottom";
          output = builtins.elemAt monitors 0;
          position = "top";
          name = "mainBar";
          margin-left = 8;
          margin-top = 5;
          margin-right =
            if desktop
            then 8
            else 5;
          mode = "dock";
          "gtk-layer-shell" = true;

          modules-left = [
            "hyprland/workspaces"
            "cava"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "group/hardware"
            "clock"
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
            hide_on_silence = false;
            stereo = true;
            reverse = true;
            bar_delimiter = 0;
            monstercat = false;
            waves = false;
            noise_reduction = 0.77;
            input_delay = 1;
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          };

          "group/hardware" = {
            orientation = "inherit";
            modules = [
              "custom/disk-icon"
              "memory"
              "cpu"
            ];
          };

          "custom/disk-icon" = {
            exec = ''
              df /dev/disk/by-partlabel/disk-main-home /dev/disk/by-partlabel/disk-main-nix | awk '
                function format(size) {
                  if (size >= 1024) return sprintf("%.1fTB", size / 1024)
                  else return sprintf("%.1fGB", size)
                }
                $6 == "/home" {
                  home_usage = $3 / 1024 / 1024
                  home_total = $2 / 1024 / 1024
                  home_percent = $5
                  sub(/%/,"",home_percent)
                }
                $6 == "/nix" {
                  nix_usage = $3 / 1024 / 1024
                  nix_total = $2 / 1024 / 1024
                  nix_percent = $5
                }
                END {
                  printf "{\"class\": \"disk-icon\", \"tooltip\": \"/home: %s / %s\\n/nix: %s / %s\", \"percentage\": \"%s\"}\n",
                  format(home_usage), format(home_total), format(nix_usage), format(nix_total), home_percent
                }' | jq --unbuffered --compact-output
            '';
            interval = 60;
            return-type = "json";
            rotate = 270;
            format = "{icon}";
            format-icons = [
              "󰝦"
              "󰪞"
              "󰪟"
              "󰪠"
              "󰪡"
              "󰪢"
              "󰪣"
              "󰪤"
              "󰪥"
            ];
          };

          memory = {
            interval = 1;
            rotate = 270;
            format = "{icon}";
            format-icons = [
              "󰝦"
              "󰪞"
              "󰪟"
              "󰪠"
              "󰪡"
              "󰪢"
              "󰪣"
              "󰪤"
              "󰪥"
            ];
            max-length = 10;
            tooltip-format = "RAM: {used:0.1f} GB / {total:0.1f} GB";
          };

          cpu = {
            interval = 1;
            rotate = 270;
            format = "{icon}";
            format-icons = [
              "󰝦"
              "󰪞"
              "󰪟"
              "󰪠"
              "󰪡"
              "󰪢"
              "󰪣"
              "󰪤"
              "󰪥"
            ];
            tooltip-format = "CPU: {usage:0.1f}%";
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

          clock = {
            format = "{:%I:%M %p}";
            tooltip = false;
          };
        };
        sideBar = {
            layer = "bottom";
            output =
              if desktop
              then builtins.elemAt monitors 1
              else builtins.elemAt monitors 0;
            position = "right";
            margin-top = 8;
            margin-right = 5;
            margin-bottom = 8;
            name = "sideBar";
            mode = "dock";
            "gtk-layer-shell" = true;

            modules-left =
              if desktop
              then [
                "hyprland/workspaces"
              ]
              else [
                "group/brightness"
                "battery"
              ];
            modules-center = [
            ];
            modules-right = [
              "network"
              "group/audio"
            ];

            "hyprland/workspaces" = workspaces;

            "pulseaudio/slider" = {
              orientation = "vertical";
            };

            "group/audio" = {
              orientation = "vertical";
              modules = [
                "pulseaudio/slider"
                "pulseaudio"
              ];
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

            battery = {
              bat = "BAT1";
              interval = 1;
              tooltip-format = "{capacity}%\nTil empty: {time}";
              tooltip-format-charging = "{capacity}%\nTil full: {time}";
              format = "{icon}";
              format-icons = [
                "󰁺"
                "󰁻"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
              format-charging = "󰂄";
            };

            "group/brightness" = {
              orientation = "vertical";
              modules = [
                "backlight"
                "backlight/slider"
              ];
            };
            backlight = {
              format = "󰃠";
              tooltip = "{percentage}%";
            };
            "backlight/slider" = {
              min = 10;
              max = 100;
              orientation = "vertical";
              rotate = 180;
            };
        };
      };
      style = ''
          * {
            border: none;
            border-radius: 0;
            font-size: 16px;
            font-family: "JetBrains Mono Nerd Font";
          }

          window#waybar {
            border-radius: 10px;
            border: 3px solid #${fg.light};
            background: rgba(23,29,35,0.50);
            margin: 20px;
          }
          window#waybar.empty #window {
            background: none;
            border: none;
          }

          #workspaces {
            margin: 3px;
            background: #${bg.darker};
            border: 3px solid #${bg.dark};
            border-radius: 8px;
          }

          #workspaces button:hover {
            border-radius: 8px;
          }

          #workspaces button.active {
            background: #${fg.lightester};
            border-radius: 8px;
            color: #${bg.darkest};
          }

          #cava {
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            margin: 3px 3px 3px 6px;
            padding: 0px 15px 0px 15px;
            color: #${colors.color6};
          }

          #window {
            margin: 3px;
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            padding: 0 15px 0 15px;
            font-weight: bold;
          }

          #hardware {
            margin: 3px;
            padding: 0 10px 0 10px;
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
          }

          #custom-disk-icon, #cpu, #memory {
            margin-bottom: 4px;
            font-size: 20px;
            font-weight: bold;
          }

          #custom-disk-icon {
            color: #${colors.color4};
          }

          #memory {
            color: #${colors.color1};
          }

          #cpu {
            color: #${colors.color3};
          }

          #clock {
            font-weight: bold;
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            margin: 3px;
            padding: 0 10px 0 10px;
            font-size: 18px;
          }

          #powerbtns {
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            margin: 3px;
            padding: 0 5px 0 10px;
          }

          #custom-power {
            color: #${colors.color2};
            font-size: 18px;
          }

          #custom-logout {
            color: #${colors.color4};
            font-size: 18px;
          }

          #custom-reboot {
            color: #${colors.color0};
            font-size: 18px;
          }

          #audio {
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            margin: 3px;
            padding: 5px 0 10px 0;
          }

          #pulseaudio {
            color: #${colors.color1};
            font-size: 18px;
          }

          #backlight-slider slider,
          #pulseaudio-slider slider {
                background: #${colors.color4};
                background-color: transparent;
                box-shadow: none;
              }

          #backlight-slider trough,
          #pulseaudio-slider trough {
            min-width: 9px;
            min-height: 90px;
            border-radius: 8px;
            background: #121212;
          }

          #backlight-slider highlight,
          #pulseaudio-slider highlight {
            border-radius: 8px;
            background-color: #${colors.color4};
          }

          #network {
            color: #${colors.color1};
            font-size: 20px;
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            margin: 3px;
            padding: 5px 0 5px 6px;
          }

          #brightness {
            background: #${bg.darker};
            border-radius: 8px;
            border: 3px solid #${bg.dark};
            margin: 3px;
            padding: 10px 0px 5px 0;
          }

          #backlight {
            color: #${colors.color4};
            font-size: 18px;
            padding: 0 4px 0 0;
          }

          #battery {
            color: #${colors.color4};
            font-size: 20px;
            background: #${bg.darker};
            border: 3px solid #${bg.dark};
            border-radius: 8px;
            margin: 3px;
            padding: 5px 0 5px 0px;
          }
      '';
    };
  };
}
