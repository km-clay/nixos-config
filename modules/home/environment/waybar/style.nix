{
scheme,
...
}: 

let
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
in
{
  programs.waybar.style = ''
    * {
      font-family: "JetBrains Mono Nerd Font";
      font-weight: bold;
      font-size: 14;
    }

    #battery {
      font-weight: normal;
      font-size: 22px;
      color: #a6d189;
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    #tray menu * {
      font-weight: bold;
      font-size: 13px;
      color: #FBF1C7;
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    #taskbar button {
      box-shadow: none;
      font-size: 4px;
      border-radius: 9px;
      color: #A1BDCE;
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    tooltip {
      background: #${bg.darkester};
      color: #${fg.lighter};
      font-size: 13px;
      border-radius: 7px;
      border: 2px solid #${bg.dark};
      background: #${bg.darkest};
    }

    window#waybar {
      opacity: 0.85;
      background: #${bg.darkester};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    #workspaces {
      font-weight: normal;
      color: transparent;
			margin-left: -5px;
			margin-top: 0px;
			border: 0px;
      border-radius: 6px;
    }



    #backlight-slider slider,
    #pulseaudio-slider slider {
      background: #${colors.color3};
      background-color: transparent;
      box-shadow: none;
    }

    #backlight-slider trough,
    #pulseaudio-slider trough {
      min-width: 9px;
      min-height: 90px;
      border-radius: 8px;
      background: #343434;
    }

    #backlight-slider highlight,
    #pulseaudio-slider highlight {
      border-radius: 8px;
      background-color: #2096C0;
    }

    #pulseaudio {
      font-weight: normal;
      font-size: 18px;
      color: #${colors.color3};
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
			margin: 4px;
			margin-bottom: 0px;
			border: 2px solid @unfocused_borders;
			border-bottom: 2px solid #151515;
			border-radius: 6px;
			border-bottom-left-radius: 0px;
			border-bottom-right-radius: 0px;
    }

    #network {
      font-size: 19px;
      color: #${colors.color4};
      background: #${bg.darkest};
			margin: 4px;
			margin-top: 0;
			border: 2px solid @unfocused_borders;
			border-top: 2px solid #151515;
			border-radius: 6px;
			border-top-left-radius: 0px;
			border-top-right-radius: 0px;
    }

    #clock {
      color: #${colors.color6};
      font-size: 15px;
      font-weight: 900;
      font-family: "CaskaydiaCove Nerd Font Mono";
      background: #${bg.darkest};
			margin: 4px;
      border-radius: 6px;
			border: 2px solid @unfocused_borders;
			border-radius: 6px;
    }

    #custom-notification {
      font-family: "JetBrains Mono Nerd Font";
			font-size: 21px;
      color: #${colors.color7};
      background: #${bg.darkest};
			margin: 4px;
			border: 2px solid @unfocused_borders;
			border-radius: 6px;
    }

    #custom-power {
      font-size: 15px;
      color: #FFFFFF;
      background: rgba(22, 19, 32, 0.9);
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    #backlight {
      color: #${fg.lighter};
      font-weight: normal;
      font-size: 19px;
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    #custom-spacer {
      opacity: 0.0;
    }

    #tray menu separator {
      min-height: 10px;
    }


    #cpu {
      font-weight: normal;
      font-size: 22px;
      color: #${fg.lighter};
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }

    #memory {
      font-weight: normal;
      font-size: 22px;
      color: #${fg.lighter};
      background: #${bg.darkest};
      border: 2px solid #${bg.dark};
      border-radius: 6px;
    }
  '';
}
