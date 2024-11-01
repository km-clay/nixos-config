{scheme, ...}: let
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
in {
  programs.waybar.style = ''
    * {
      border: none;
      border-radius: 0;
      font-size: 16px;
      font-family: "JetBrains Mono Nerd Font";
    }

    window#waybar {
      border-radius: 20px;
      border: 3px solid #${colors.color7};
      background: rgba(46,52,64,0.15);
      margin: 20px;
    }
    window#waybar.empty #window {
      background: none;
    }

    #workspaces {
      margin: 3px;
      background: #${bg.dark};
      border-radius: 20px;
    }

    #workspaces button:hover {
      border-radius: 20px;
    }

    #workspaces button.active {
      background: #${fg.lightester};
      border-radius: 20px;
      color: #${bg.darkest};
    }

    #cava {
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px 3px 3px 6px;
      padding: 0px 15px 0px 15px;
      color: #${colors.color6};
    }

    #window {
      margin: 3px;
      background: #${bg.dark};
      border-radius: 20px;
      padding: 0 15px 0 15px;
      font-weight: bold;
    }

    #hardware {
      margin: 3px;
      padding: 0 10px 0 10px;
      background: #${bg.dark};
      border-radius: 20px;
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
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px;
      padding: 0 10px 0 10px;
      font-size: 18px;
    }

    #powerbtns {
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px;
      padding: 0 5px 0 10px;
    }

    #custom-power {
      color: #${colors.color0};
      font-size: 18px;
    }

    #custom-logout {
      color: #${colors.color4};
      font-size: 18px;
    }

    #custom-reboot {
      color: #${colors.color2};
      font-size: 18px;
    }

    #audio {
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px;
      padding: 5px 0 10px 0;
    }

    #pulseaudio {
      color: #${colors.color4};
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
      background: #343434;
    }

    #backlight-slider highlight,
    #pulseaudio-slider highlight {
      border-radius: 8px;
      background-color: #2096C0;
    }

    #network {
      color: #${colors.color3};
      font-size: 20px;
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px;
      padding: 5px 0 5px 6px;
    }

    #brightness {
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px;
      padding: 10px 0px 5px 0;
    }

    #backlight {
      color: #${colors.color2};
      font-size: 18px;
      padding: 0 4px 0 0;
    }

    #battery {
      color: #${colors.color4};
      font-size: 20px;
      background: #${bg.dark};
      border-radius: 20px;
      margin: 3px;
      padding: 5px 0 5px 0px;
    }
  '';
}
