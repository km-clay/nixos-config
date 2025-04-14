{ inputs, pkgs, lib, config, self, host, ... }:
let
  desktop = host == "oganesson";
  screenshot_bind = if desktop then
  [ "super, print, exec, grimblast copy area"
    "super shift, print, exec, grimblast --freeze copy area"
]
  else
    [
      # My laptop does not have a printscreen button
      "super, insert, exec, grimblast copy area"
    ];
  scheme = config.lib.stylix.colors;
  mons = config.movOpts.envConfig.hyprlandConfig.monitorNames;

in {

  options = {
    movOpts.envConfig.hyprlandConfig = {
      enable = lib.mkEnableOption "enables my hyprland config";
      workspaceLayout = lib.mkOption {
        type = lib.types.str;
        default = "dualmonitor";
      };
      monitorNames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        # The order of the monitor names matters for the purpose of workspace assignment
        # For instance, in a dual monitor setup, index 0 gets 4,5 and 6, while index 1 gets 1,2 and 3
        default = [ "DP-1" "HDMI-A-1" ];
      };
    };
  };
  config = lib.mkIf config.movOpts.envConfig.hyprlandConfig.enable {
    home.packages = with pkgs; [
      swaybg
      inputs.hypr-contrib.packages.${pkgs.system}.grimblast
      hyprpicker
      grim
      slurp
      wl-clip-persist
      wf-recorder
      glib
      wayland
      direnv
    ];
    systemd.user.targets.hyprland-session.Unit.Wants =
      [ "xdg-desktop-autostart.target" ];
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = { enable = true; };
      systemd.enable = true;
    };
    wayland.windowManager.hyprland = {
      settings = {
        monitor = if (host == "oganesson") then [
          "DP-1, 1920x1080@144, 1920x0, 1"
          "HDMI-A-1, 1920x1080, 0x0, 1"
        ] else
          [ "eDP-1, 1600x900, 0x0, 1" ];

        exec-once = [
          "waybar &"
          "swaync &"
          "wl-paste --type text --watch cliphist store &"
          "wl-paste --type image --watch cliphist store &"
          "wl-clip-persist --clipboard both"
          "systemctl --user import-environment &"
          "hash dbus-update-activation-environment 2>/dev/null &"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
        ];

        workspace = if (config.movOpts.envConfig.hyprlandConfig.workspaceLayout == "dualmonitor") then [
            "1,persistent=true,monitor:${builtins.elemAt mons 0}"
            "2,persistent=true,monitor:${builtins.elemAt mons 0}"
            "3,persistent=true,monitor:${builtins.elemAt mons 0}"
            "4,persistent=true,monitor:${builtins.elemAt mons 1}"
            "5,persistent=true,monitor:${builtins.elemAt mons 1}"
            "6,persistent=true,monitor:${builtins.elemAt mons 1}"
          ] else if (config.movOpts.envConfig.hyprlandConfig.workspaceLayout == "singlemonitor") then [
              "1,persistent=true,monitor:${builtins.elemAt mons 0} "
              "2,persistent=true,monitor:${builtins.elemAt mons 0}"
              "3,persistent=true,monitor:${builtins.elemAt mons 0}"
              "4,persistent=true,monitor:${builtins.elemAt mons 0}"
            ] else if (config.movOpts.envConfig.hyprlandConfig.workspaceLayout == "trimonitor") then [
                "1,persistent=true,monitor:${builtins.elemAt mons 2}"
                "2,persistent=true,monitor:${builtins.elemAt mons 2}"
                "3,persistent=true,monitor:${builtins.elemAt mons 1}"
                "4,persistent=true,monitor:${builtins.elemAt mons 1}"
                "5,persistent=true,monitor:${builtins.elemAt mons 0}"
                "6,persistent=true,monitor:${builtins.elemAt mons 0}"
              ] else [ ];

        env = [
          "XDG_CONFIG_HOME,$HOME/.config"
          "XDG_DATA_HOME,$HOME/.local/share"
          "XDG_CACHE_HOME,$HOME/.cache"
        ];
        layerrule = [ "blur,waybar" "ignorezero,waybar" "blur,launcher" ];
        windowrule = [ "opacity 0.8,nemo" ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          accel_profile = "flat";
          force_no_accel = 1;
          sensitivity = 0;
        };
        general = {
          "$mainMod" = "super";
          layout = "dwindle";
          gaps_in = 4;
          gaps_out = 8;
          border_size = 3;
          #"col.inactive_border" = "0xff${scheme.base01}";
          "col.active_border" = lib.mkForce "0xff${scheme.base04}";
          border_part_of_window = false;
          no_border_on_floating = false;
        };
        misc = {
          disable_autoreload = true;
          disable_hyprland_logo = true;
          always_follow_on_dnd = true;
          layers_hog_keyboard_focus = true;
          animate_manual_resizes = false;
          enable_swallow = true;
          focus_on_activate = true;
        };

        dwindle = {
          force_split = 0;
          special_scale_factor = 1.0;
          split_width_multiplier = 1.0;
          use_active_for_splits = true;
          pseudotile = "yes";
          preserve_split = "yes";
        };

        master = {
          new_status = "master";
          special_scale_factor = 1;
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;
            # size = 1;
            # passes = 1;
            size = 2;
            passes = 1;
            brightness = 1;
            contrast = 1.4;
            ignore_opacity = true;
            popups = true;
            noise = 0;
            new_optimizations = true;
            xray = true;
          };

        };

        animations = {
          enabled = true;

          bezier = [
            "fluent_decel, 0, 0.2, 0.4, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutCubic, 0.33, 1, 0.68, 1"
            "easeinoutsine, 0.37, 0, 0.63, 1"
          ];

          animation = [
            # Windows
            "windowsIn, 1, 3, easeOutCubic, popin 30%" # window open
            "windowsOut, 1, 3, fluent_decel, popin 70%" # window close.
            "windowsMove, 1, 2, easeinoutsine, slide" # everything in between, moving, dragging, resizing.

            # Fade
            "fadeIn, 1, 3, easeOutCubic" # fade in (open) -> layers and windows
            "fadeOut, 1, 2, easeOutCubic" # fade out (close) -> layers and windows
            "fadeSwitch, 0, 1, easeOutCirc" # fade on changing activewindow and its opacity
            "fadeShadow, 1, 10, easeOutCirc" # fade on changing activewindow for shadows
            "fadeDim, 1, 4, fluent_decel" # the easing of the dimming of inactive windows
            "border, 1, 2.7, easeOutCirc" # for animating the border's color switch speed
            "borderangle, 1, 30, fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
            "workspaces, 1, 4, easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
          ];

          bind = [
            "super, up, exec, pactl set-sink-volume @default_sink@ +10%"
            "super, down, exec, pactl set-sink-volume @default_sink@ -10%"
            "super, t, exec, swaync-client -t -sw"
            "super, a, exec, librewolf"
            "super, q, exec, kitty"
            "super shift, q, exec, [float;size 40% 30%;move onscreen cursor -50% -50%] kitty"
            "super, c, killactive,"
            "super shift, c,exec, hyprctl kill"
            "super, e, exec, [float;size 40% 50%;move onscreen cursor -50% -50%] nemo"
            "super, p, exec, [float;size 40% 25%;move onscreen cursor] [ ! -f /tmp/keyringfile ] && kitty toolbelt"
            "super shift, m, exit,"
            "super, m, exec, fuzzel"
            "super, r, exec, neovide"
            "super, b, togglesplit, # dwindle"
            "super, f, togglefloating"
            "super, g, fullscreen"
            "super, h, movefocus, l"
            "super, l, movefocus, r"
            "super, k, movefocus, u"
            "super, j, movefocus, d"
            "super shift, h, movewindow, l"
            "super shift, l, movewindow, r"
            "super shift, k, movewindow, u"
            "super shift, j, movewindow, d"
            "super, d, exec, switchmon"
            "super, 1, exec, hyprctl 'dispatch workspace 1'"
            "super, 2, exec, hyprctl 'dispatch workspace 2'"
            "super, 3, exec, hyprctl 'dispatch workspace 3'"
            "super, 4, exec, hyprctl 'dispatch workspace 4'"
            "super, 5, exec, hyprctl 'dispatch workspace 5'"
            "super, 6, exec, hyprctl 'dispatch workspace 6'"
            "super shift, 1, movetoworkspace, 1"
            "super shift, 2, movetoworkspace, 2"
            "super shift, 3, movetoworkspace, 3"
            "super shift, 4, movetoworkspace, 4"
            "super shift, 5, movetoworkspace, 5"
            "super shift, 6, movetoworkspace, 6"
            "super, s, togglespecialworkspace, magic"
            "super shift, s, movetoworkspace, special:magic"
          ] ++ screenshot_bind;
          bindm =
            [ "super, mouse:272, movewindow" "super, mouse:273, resizewindow" ];
        };
      };
    };
  };
}
