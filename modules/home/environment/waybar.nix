{ pkgs, host, lib, config, ... }:

let
  desktop = (host == "oganesson");
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
      if (layout == "singlemonitor") then {
          "${builtins.elemAt monitors 0}" = [ 1 2 3 4 ];
        } else if (layout == "dualmonitor") then {
            "${builtins.elemAt monitors 0}" = [ 1 2 3 ];
            "${builtins.elemAt monitors 1}" = [ 4 5 6 ];
          } else if (layout == "trimonitor") then {
              "${builtins.elemAt monitors 2}" = [ 1 2 ];
              "${builtins.elemAt monitors 1}" = [ 3 4 ];
              "${builtins.elemAt monitors 0}" = [ 5 6 ];
            } else
        { };

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
  monitors = config.movOpts.envConfig.hyprlandConfig.monitorNames;
  circle-gauge =  [ "󰝦" "󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥" ];
  cava-gauge =    [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
  battery-gauge = [ "󰁺" "󰁻" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
	bar-gauge = [
		"░░░░░░░░"
		"█░░░░░░░"
		"██░░░░░░"
		"███░░░░░"
		"████░░░░"
		"█████░░░"
		"██████░░"
		"███████░"
		"████████"
	];
in {
  options = {
    movOpts.envConfig.waybarConfig.enable =
      lib.mkEnableOption "enables my waybar configuration";
  };
  config = {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      });
      settings = {
        mainBar = {
          layer = "top";
          output = if layout == "singlemonitor" then builtins.elemAt monitors 0
                    else builtins.elemAt monitors 1;
          position = "top";
          name = "mainBar";
          margin-left = 0;
          margin-top = 0;
          margin-right = 0;
          mode = "dock";
					exclusive = true;
					passthrough = false;
          "gtk-layer-shell" = true;

          modules-left = [ "clock" "hyprland/workspaces" "tray" ];
          modules-center = [];
          modules-right = [ "cpu" "memory" "pulseaudio" "network" ];

          "hyprland/workspaces" = workspaces;

          clock = {
            format = "[ CLK: {:%H.%M <span size='8pt'> %a %b %d</span>} ]";
						tooltip-format = "<tt>{calendar}</tt>";
						calendar = {
							mode = "month";
							weeks-pos = "";
							on-scroll = 1;
							format = {
								months = "<span size='16pt'><b>CAL: {}\n</b></span>";
								days = "<span size='16pt'><b>{}</b></span>";
								weeks = "<span size='16pt'><b>{}</b></span>";
								weekdays = "<span size='16pt'><b>{}</b></span>";
								today = "<span color='#E6E1CF'><b>{}</b></span>";
							};
						};
						actions = {
							on-scroll-up = "shift_down";
							on-scroll-down = "shift_up";
						};
          };

					pulseaudio = {
						format = "VOL: [ <span color='#272D38'>{icon}</span> ] <span size='8pt'>{volume}%</span>";
						tooltip = true;
						tooltip-format = "DEVICE: {desc}";
						format-muted = "VOL: <span color='#F07178'>[ XXXXXXXX ] <span size='8pt'>{volume}%</span></span>";
						on-click = "if [ $(pamixer --get-mute) == true ]; then pamixer --unmute; else pamixer --mute; fi";
						on-scroll-up = "pamixer -i 2";
						on-scroll-down = "pamixer -d 2";
						scroll-step = 2;
						reverse-scrolling = true;
						format-icons = bar-gauge;
					};

					network = {
						format-wifi = "[ <span color='#B8CC52'>ONLINE</span> ]";
						format-ethernet = "[ <span color='#B8CC52'>ONLINE</span> ]";
						tooltip-format-wifi = "ESSID\t: {essid}\nSTRNGTH\t: {signaldBm}\n\nADDRESS\t: {ipaddr}\nGATE\t: {gwaddr}\nMASK\t: {netmask} | {cidr}";
						tooltip-format-ethernet = "IFNAME: {ifname}\nADDRESS: {ipaddr}";
						format-disconnected = "[ <span color='#F07178'>XXXXXX</span> ]";
						on-click = "nm-connection-editor";
					};

					memory = {
						interval = 20;
						format = "MEM: [ <span color='#272D38'>{icon}</span> ] <span size='8pt'>{percentage}%</span>";
						tooltip-format = "MEM_TOT\t: {total}GiB\nSWP_TOT\t: {swapTotal}GiB\n\nMEM_USD\t: {used:0.1f}GiB\nSWP_USD\t: {swapUsed:0.1f}GiB";
						format-icons = [
							"░░░░░░░░"
							"█░░░░░░░"
							"██░░░░░░"
							"███░░░░░"
							"████░░░░"
							"█████░░░"
							"██████░░"
							"<span color='#F07178'>!!!!!!!!</span>"
							"<span color='#F07178'>CRITICAL</span>"
						];
					};

					cpu = {

						interval = 1;
						format = "CPU: [ <span color='#272D38'>{icon}</span> ] <span size='8pt'>{usage}%</span>";
						tooltip = true;
						format-icons = [
							"░░░░░░░░"
							"█░░░░░░░"
							"██░░░░░░"
							"███░░░░░"
							"████░░░░"
							"█████░░░"
							"██████░░"
							"<span color='#272D38'>!!!!!!!!</span>"
							"<span color='#272D38'>CRITICAL</span>"
						];
					};
        };
      };
      style = ''
				* {
					font-size: 14px;
					border: none;
					font-family: EnvyCodeR Nerd Font Mono;
					font-weight: Bold;
					min-height: 0;
					border-radius: 0px;
					padding: 2px;
				}

				window#waybar {
					color: #${fg.lightest};
					background: #${bg.darkester};
				}

				tooltip {
					background: #${bg.darkester};
				}

				#workspaces button {
					color: #${fg.lightest};
					background: #${bg.darkester};
				}

				#workspaces button.active {
					color: #${bg.darker};
					background: #${bg.darkester};
				}

				#workspaces button.focused {
					color: #${bg.dark};
					background: #${bg.darkester};
				}

				#workspaces button.urgent {
					color: #${fg.lightest};
					background: #${bg.darkester};
				}

				#workspaces button:hover {
					color: #${fg.lightest};
					background: #${bg.darkester};
				}

				#window,
				#clock,
				#pulseaudio,
				#network,
				#workspaces,
				#tray,
				#cpu {
					padding: 0px 10px;
					margin: 0px;
				}

				#tray {
					margin-right: 10px;
				}

				#workspaces {
					color: #${fg.lightest};
				}

				#window {
					color: #${fg.lightest};
				}

				#clock {
					color: #${fg.lightest};
				}

				#network {
					color: #${fg.lightest};
				}

				#pulseaudio {
					color: #${fg.lightest};
				}
      '';
    };
  };
}
