{...}: let
  custom = {
    font_size = "15px";  # Base font size
    font_weight = "bold"; # Base font weight
    notification_font_size = "18px"; # Font size for notifications
    text_color = "#cccedb";  # Default text color
    background_color = "rgba(21, 21, 21, 0.83)";
    border_color = "rgba(255, 255, 255, 0.3)";
    notification_margin_left = "-2px";
    notification_margin_top = "-4px";
    notification_padding_bottom = "12px";
    tooltip_bg = "#1D2021";
    tooltip_color = "#FBF1C7";
    tooltip_border = "#101a24";
  };
in {
  programs.waybar.style = ''
    * {
      font-family: "JetBrains Mono Nerd Font";
      font-weight: ${custom.font_weight};
      font-size: ${custom.font_size};
    }

    #custom-notification {
      font-family: "JetBrains Mono Nerd Font";
      font-size: ${custom.notification_font_size};
      color: ${custom.text_color};
      margin-left: ${custom.notification_margin_left};
      margin-top: ${custom.notification_margin_top};
      padding-bottom: ${custom.notification_padding_bottom};
    }

    window#waybar {
      background: ${custom.background_color};
      border: 3px solid ${custom.border_color};
      border-radius: 6px;
    }

    tooltip {
      background: ${custom.tooltip_bg};
      color: ${custom.tooltip_color};
      font-size: 13px;
      border-radius: 7px;
      border: 2px solid ${custom.tooltip_border};
    }

    #workspaces {
      font-weight: normal;
      background: rgba(23, 23, 23, 0.0);
      color: #2F302D;
      border-radius: 9px;
      padding-left: 0px;
      padding-right: 4px;
      padding-top: 1px;
    }

    #workspaces button {
      font-weight: normal;
      background: rgba(23, 23, 23, 0.0);
      color: #B1B2BD;
      border-radius: 9px;
      padding-left: 0px;
      padding-right: 4px;
      margin-right: -4px;
      margin-top: -10px;
    }

    #workspaces button.active {
      color: ${custom.text_color};
      font-weight: normal;
      padding-left: 0px;
      padding-right: 4px;
      transition: all 0.3s ease;
    }

    #taskbar button {
      box-shadow: none;
      font-size: 4px;
      padding: 0px;
      border-radius: 9px;
      margin-top: 3px;
      margin-bottom: 3px;
      margin-left: 3px;
      margin-right: 3px;
      color: #A1BDCE;
    }

    #taskbar button.active {
      background: #C8C8C8;
      color: #C8C8C8;
      margin-left: 10px;
      margin-right: 10px;
      border-radius: 3px;
    }

    #tray menu * {
      font-weight: bold;
      font-size: 13px;
      color: #FBF1C7;
    }

    #tray {
      padding: 0px;
    }

    #battery {
      font-weight: normal;
      font-size: 22px;
      color: #a6d189;
    }

    #clock {
      color: ${custom.text_color};
      font-size: 15px;
      font-weight: 900;
      font-family: "CaskaydiaCove Nerd Font Mono";
      background: rgba(23, 23, 23, 0.0);
    }

		#backlight-slider slider,
    #pulseaudio-slider slider {
      background: #A1BDCE;
      background-color: transparent;
      box-shadow: none;
    }

    #backlight-slider trough,
    #pulseaudio-slider trough {
      min-width: 9px;
      min-height: 90px;
      margin-bottom: -4px;
      border-radius: 8px;
      background: #343434;
      margin-left: -4px;
      margin-right: -4px;
    }

    #backlight-slider highlight,
    #pulseaudio-slider highlight {
      border-radius: 8px;
      background-color: #2096C0;
    }

    #custom-mouse {
      font-size: 14px;
      margin-bottom: 6px;
      background: #161320;
    }

    #custom-power {
      font-size: 15px;
      color: #FFFFFF;
      background: rgba(22, 19, 32, 0.9);
      margin: 6px 0px;
      padding-left: 4px;
      padding-right: 4px;
    }

    #backlight {
      color: ${custom.text_color};
      font-weight: normal;
      font-size: 19px;
      margin: 0px;
      padding-left: 0px;
    }

    #custom-spacer {
      opacity: 0.0;
      padding-top: 3px;
    }

    #tray menu separator {
      min-height: 10px;
    }

    #pulseaudio {
      font-weight: normal;
      font-size: 18px;
      color: ${custom.text_color};
    }

    #cpu {
      font-weight: normal;
      font-size: 22px;
      color: ${custom.text_color};
    }

    #memory {
      font-weight: normal;
      font-size: 22px;
      color: ${custom.text_color};
    }

    #network {
      font-size: 19px;
      color: ${custom.text_color};
    }
  '';
}
