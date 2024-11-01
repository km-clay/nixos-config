{pkgs}:
pkgs.writeShellScriptBin "moveonscreen" ''
  center_window=false
  if [[ $1 == "--center" ]]; then
      center_window=true
  fi

  cursor_pos=$(hyprctl cursorpos | sed 's/,//')
  cursor_x=$(echo "$cursor_pos" | awk '{print $1}')
  cursor_y=$(echo "$cursor_pos" | awk '{print $2}')


  window_info=$(hyprctl activewindow -j)
  window_width=$(echo "$window_info" | jq ".size[0]")
  window_height=$(echo "$window_info" | jq ".size[1]")


  if [ "$center_window" = true ]; then
      cursor_x=$((cursor_x - window_width / 2))
      cursor_y=$((cursor_y - window_height / 2))

      if (( cursor_x < 10 )); then
          cursor_x=10
      fi
      if (( cursor_y < 54 )); then
          cursor_y=54
      fi
  fi

  monitors=$(hyprctl monitors -j)

  monitor_x_min=0
  monitor_x_max=0
  monitor_y_min=0
  monitor_y_max=0
  focused_monitor=-1

  for ((i = 0; i < $(echo "$monitors" | jq 'length'); i++)); do
      mon_x=$(echo "$monitors" | jq ".[$i].x")
      mon_y=$(echo "$monitors" | jq ".[$i].y")
      mon_width=$(echo "$monitors" | jq ".[$i].width")
      mon_height=$(echo "$monitors" | jq ".[$i].height")
      is_focused=$(echo "$monitors" | jq ".[$i].focused")

      if [ "$is_focused" = true ]; then
  			monitor_x_min=$((mon_x + 10))
          monitor_x_max=$((mon_x + mon_width - 10))
  				monitor_y_min=$((mon_y + 10))
          monitor_y_max=$((mon_y + mon_height - 10))
          focused_monitor=$i
          break
      fi
  done

  if [ "$focused_monitor" -eq -1 ]; then
      exit 1
  fi

  if (( cursor_x < monitor_x_min )); then
      adjusted_x=$monitor_x_min
  elif (( cursor_x + window_width > monitor_x_max )); then
      adjusted_x=$((monitor_x_max - window_width))
  else
      adjusted_x=$cursor_x
  fi

  if (( cursor_y < monitor_y_min )); then
      adjusted_y=$monitor_y_min
  elif (( cursor_y + window_height > monitor_y_max )); then
      adjusted_y=$((monitor_y_max - window_height))
  else
      adjusted_y=$cursor_y
  fi

  hyprctl dispatch moveactive exact "$adjusted_x $adjusted_y" > /dev/null 2>&1
''
