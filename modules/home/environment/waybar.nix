{
  pkgs,
  lib,
  config,
  self,
  ...
}:

let
  layout = config.movOpts.envConfig.hyprlandConfig.workspaceLayout;
  workspaces = {
    format = "{icon}";
    format-icons = {
      "1" = "1";
      "2" = "2";
      "3" = "3";
      "4" = "4";
      "5" = "5";
      "6" = "6";
      "7" = "7";
      "8" = "8";
      "9" = "9";
      "10" = "10";
      "11" = "11";
      "12" = "12";
      "13" = "13";
      "14" = "14";
      "15" = "15";
      "16" = "16";
      "17" = "17";
      "18" = "18";
      "19" = "19";
      "20" = "20";
    };
    persistent-workspaces =
      if (layout == "singlemonitor") then
        {
          "${builtins.elemAt monitors 0}" = [
            1
            2
            3
            4
          ];
        }
      else if (layout == "dualmonitor") then
        {
          "${builtins.elemAt monitors 0}" = [
            1
            2
            3
          ];
          "${builtins.elemAt monitors 1}" = [
            4
            5
            6
          ];
        }
      else if (layout == "trimonitor") then
        {
          "${builtins.elemAt monitors 0}" = [
            1
            2
          ];
          "${builtins.elemAt monitors 1}" = [
            3
            4
          ];
          "${builtins.elemAt monitors 2}" = [
            5
            6
          ];
        }
      else
        { };

  };

  monitors = config.movOpts.envConfig.hyprlandConfig.monitorNames;
in
{
  options = {
    movOpts.envConfig.waybarConfig.enable = lib.mkEnableOption "my waybar configuration";
  };
  config = lib.mkIf config.movOpts.envConfig.waybarConfig.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          output = monitors;
          position = "top";
          name = "waybar";
          margin-left = 0;
          margin-top = 0;
          margin-right = 0;
          exclusive = true;
          passthrough = false;
          "gtk-layer-shell" = true;

          modules-left = [
            "tray"
            "hyprland/workspaces"
          ];
          modules-center = [ "hyprland/window" ];

          "hyprland/window" = {
            format = "<span color='#aaaaaa'>{title}</span>";
          };
          modules-right = [
            "cpu"
            "memory"
            "pulseaudio"
            "network"
            "clock"
            "image#nixicon"
          ];

          "hyprland/workspaces" = workspaces;

          clock = {
            format = "󱑍 <span color='#aaaaaa'>{:%H:%M}</span>";
          };

          pulseaudio = {
            format = " <span color='#aaaaaa'>{volume}%</span>";
            tooltip = true;
            tooltip-format = "{desc}";
            format-muted = " <span color='#aaaaaa'>{volume}%</span>";
            on-click = "if [ $(pamixer --get-mute) == true ]; then pamixer --unmute; else pamixer --mute; fi";
            on-scroll-up = "pamixer -i 2";
            on-scroll-down = "pamixer -d 2";
            scroll-step = 2;
            reverse-scrolling = true;
          };

          network = {
            format-wifi = "󰖩 <span color='#aaaaaa'>{essid}</span>";
            format-ethernet = " <span color='#aaaaaa'>{ifname}</span>";
            tooltip-format-wifi = "ESSID\t: {essid}\nSTRNGTH\t: {signaldBm}\n\nADDRESS\t: {ipaddr}\nGATE\t: {gwaddr}\nMASK\t: {netmask} | {cidr}";
            tooltip-format-ethernet = "IFNAME: {ifname}\nADDRESS: {ipaddr}";
            format-disconnected = "󱚼";
            on-click = "nm-connection-editor";
          };

          "image#nixicon" = {
            path = "${self}/assets/images/nix-snowflake-colours.svg";
            size = 28;
          };

          memory = {
            interval = 20;
            format = " <span color='#aaaaaa'>{percentage}%</span>";
            tooltip-format = "MEM_TOT\t: {total}GiB\nSWP_TOT\t: {swapTotal}GiB\n\nMEM_USD\t: {used:0.1f}GiB\nSWP_USD\t: {swapUsed:0.1f}GiB";
          };

          cpu = {
            interval = 1;
            format = "󰍛 <span color='#aaaaaa'>{usage}%</span>";
            tooltip = true;
          };
        };
      };
      style = ''
        @define-color accent #CF1B30;
        @define-color bg-dark #1a1a1a;
        @define-color bg-island #2a2a2a;
        @define-color fg-dim #aaaaaa;
        @define-color fg-text #d0d0d0;

        * {
            font-size: 20px;
            border: none;
            font-family: EnvyCodeR Nerd Font Mono;
            font-weight: bold;
            min-height: 0;
            border-radius: 0;
        }

        window#waybar {
            background: rgba(0, 0, 0, 0.05);
            color: @fg-text;
        }

        tooltip {
            background: @bg-dark;
            border: 2px solid @accent;
            border-radius: 8px;
        }

        /* ── Tray island (far left) ── */
        #tray {
            background-color: @bg-dark;
            color: @accent;
            border: 2px solid @accent;
            border-radius: 8px;
            padding: 4px 8px;
            margin: 6px 4px 6px 10px;
        }

        /* ── Workspaces island ── */
        #workspaces {
            background-color: @bg-dark;
            border: 2px solid @accent;
            border-radius: 8px;
            margin: 6px 4px;
            padding: 0 4px;
        }

        #workspaces button {
            color: @fg-dim;
            background: transparent;
            padding: 4px 8px;
            border-radius: 6px;
            margin: 2px;
        }

        #workspaces button.active {
            color: @bg-dark;
            background-color: @accent;
        }

        #workspaces button:hover {
            color: @bg-dark;
            background-color: alpha(@accent, 0.5);
        }

        /* ── Right info modules island ── */
        #cpu,
        #memory,
        #pulseaudio,
        #network,
        #window,
        #clock {
            background-color: @bg-dark;
            color: @accent;
            border-top: 2px solid @accent;
            border-bottom: 2px solid @accent;
            padding: 4px 10px;
            margin: 6px 0;
        }

        /* ── Window title island (center) ── */
        #window {
            border-radius: 8px;
            border-left: 2px solid @accent;
            border-right: 2px solid @accent;
            margin: 6px 4px;
        }

        /* round left edge of first module in the group */
        #cpu {
            border-radius: 8px 0 0 8px;
            border-left: 2px solid @accent;
            margin-left: 4px;
        }

        /* round right edge of last module before nixicon */
        #clock {
            border-radius: 0 8px 8px 0;
            border-right: 2px solid @accent;
            margin-right: 4px;
        }

        /* ── NixOS icon island (far right, outlined) ── */
        #image {
            background-color: @bg-dark;
            color: @accent;
            border: 2px solid @accent;
            border-radius: 8px;
            padding: 4px 10px;
            margin: 6px 10px 6px 4px;
        }

        @import url("file://${config.home.homeDirectory}/.local/state/sysflake/waybar-colors.css");
      '';
    };
  };
}
