{ inputs, pkgs, lib, config, self, host, ... }:
let
  desktop = host == "oganesson";
  screenshot_bind = if desktop then
		[
			"super, print, exec, grimblast copy area"
			"super shift, print, exec, grimblast --freeze copy area"
		]
  else
		[
			# My laptop does not have a printscreen button
			"super, insert, exec, grimblast copy area"
		];
  scheme = config.lib.stylix.colors;
  mons = config.movOpts.envConfig.hyprlandConfig.monitorNames;
	smartGapsWorkspaces = [
		"w[tv1], gapsout:0, gapsin:0"
		"f[1], gapsout:0, gapsin:0"
	];
	smartGapsWindowrules = [
		"bordersize 0, floating:0, onworkspace:w[tv1]"
		"rounding 0, floating:0, onworkspace:w[tv1]"
		"bordersize 0, floating:0, onworkspace:f[1]"
		"rounding 0, floating:0, onworkspace:f[1]"
	];
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
        ] else if (host == "phosphorous") then [
          "DP-1, highrr, 0x0, 1"
          "DP-3, highrr, -1080x-420, 1, transform, 3"
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

        workspace = (if (config.movOpts.envConfig.hyprlandConfig.workspaceLayout == "dualmonitor") then [
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
              ] else [ ]) ++ smartGapsWorkspaces;

        env = [
          "XDG_CONFIG_HOME,$HOME/.config"
          "XDG_DATA_HOME,$HOME/.local/share"
          "XDG_CACHE_HOME,$HOME/.cache"
        ];
        layerrule = [ "blur,waybar" "ignorezero,waybar" "blur,launcher" ];
				windowrulev2 = [
					"float, class:^(thunar)$,title:^(.*File Operation Progress.*)$"
					"float, class:^(firefox)$,title:^(Library)$"
					"float, class:^(thunar)$,title:^(File Operation Progress)$"
					"float, class:^(thunar)$,title:^(Confirm to replace files)$"
					"float, title:^(bwarn)$"
					"float, title:^(bwarn)$"
					"noinitialfocus, class:^(steam)$"
					"float, class:^(firefox)$,title:^(ログイン - Google アカウント — Mozilla Firefox)$"
					"float, class:^(firefox)$,title:^(Firefox — Sharing Indicator)$"
					"float, class:^(firefox)$,title:^(Firefox — 共有インジケーター)$"
					"float, class:(firefox), title:^(*.Sign in.*)$"
				];
				windowrule = [
					"float, class:^(qt5ct)$"
					"float, class:^(zoom)$"
					"float, class:^(Steam)$"
					"idleinhibit focus, class:mpv"
					"float, title:^(Picture-in-Picture)$"
					"float, class:^(nm-connection-editor)$"
					"float, class:^(waypaper)$"
					"float, title:^(Sign In)(.*)$"
					"float, title:^(Firefox — 共有インジケーター)$"
					"nofocus, title:^(Firefox — 共有インジケーター)$"
					"float, class:^(firefox)$,title^(Sign in - Google Accounts — Mozilla Firefox)$"
					"size 0 0, title:^(Firefox — 共有インジケーター)$"
					"move 100%-470 15,title:^(Firefox — Sharing Indicator)$"
					"move 100%-470 15,title:^(Firefox — 共有インジケーター)$"

				] ++ smartGapsWindowrules;

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          accel_profile = "flat";
          force_no_accel = 1;
          sensitivity = 0;
        };
				general = {
					gaps_in = 5;
					gaps_out = 9;
					border_size = 3;
					"col.active_border" = lib.mkForce "rgba(404042ff)";
					"col.inactive_border" = lib.mkForce "rgba(83858a00)";
					layout = "dwindle";
					resize_on_border = true;
					no_border_on_floating = false;

					snap = {
						enabled = true;
						window_gap = 5;
					};
				};
        misc = {
          font_family = "EnvyCodeR Nerd Font Mono";
          disable_autoreload = true;
          disable_hyprland_logo = true;
          always_follow_on_dnd = true;
          layers_hog_keyboard_focus = true;
          animate_manual_resizes = false;
          swallow_regex = "^(kitty)$";
          enable_swallow = true;
          focus_on_activate = true;
          vfr = true;
          background_color = lib.mkForce "0x202020";
          mouse_move_enables_dpms = true;
        };

        dwindle = {
          force_split = 2;
          pseudotile = "yes";
          preserve_split = "yes";
        };

        master = {
          new_status = "master";
          special_scale_factor = 1;
        };

        decoration = {
          rounding = 4;

          shadow = {
						enabled = true;
						ignore_window = true;
						range = 80;
						render_power = 50;
					};
        };

				cursor = {
					hide_on_key_press = true;
				};

				experimental = {
					xx_color_management_v4 = true;
				};

        animations = {
          enabled = true;

          bezier = [
						"myBezier, 0.16, 1, 0.3, 1"
          ];

          animation = [
            "windows, 1, 7, myBezier, popin 80%"
						"fade, 1, 7, myBezier"
						"workspaces, 1, 6, myBezier, slidefade 80%"
          ];

        };

				bind = [
					"super, up, exec, pactl set-sink-volume @default_sink@ +10%"
					"super, down, exec, pactl set-sink-volume @default_sink@ -10%"
					"super, t, exec, swaync-client -t -sw"
					"super, a, exec, firefox"
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
}
