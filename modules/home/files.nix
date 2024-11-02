{lib, config, self, ...}: {
  options = {
    homeFiles.enable = lib.mkEnableOption "enables declared custom files";
  };
  config = lib.mkIf config.homeFiles.enable {
    home.file.".config/neofetch/config.conf".text = ''
      username=$(whoami)
      name_length=''${#username}
      total_width=40
      side_length=$(( (total_width - name_length - 2) / 2 ))

      top_line=$(printf "─%.0s" $(seq 1 $side_length))
      top_line="$top_line $username "
      top_line+=$(printf "─%.0s" $(seq 1 $side_length))

      if (( (total_width - name_length) % 2 != 0 )); then
          top_line+="─"
      fi

      print_info() {
          prin  "┌$top_line┐"
          info " ​ ​  " distro
          info " ​ ​  " kernel
          info " ​ ​  " wm
          info " ​ ​  " shell
          info " ​ ​  " term
          info " ​ ​  " term_font
          info " ​ ​ 󰏗 " packages
          prin "└────────────────────────────────────────┘"
          info cols
      prin "\n \n \n \n \n ''${cl3} \n \n ''${cl5} \n \n ''${cl2} \n \n ''${cl6}  \n \n ''${cl4}  \n \n ''${cl1}  \n \n ''${cl7}  \n \n ''${cl0}"
      }

      kernel_shorthand="on"
      distro_shorthand="on"
      os_arch="off"
      uptime_shorthand="on"
      memory_percent="on"
      package_managers="off"
      shell_path="off"
      shell_version="on"
      speed_type="bios_limit"
      speed_shorthand="on"
      gtk_shorthand="on"
      gtk2="on"
      gtk3="on"
      colors=(distro)
      bold="on"
      underline_enabled="on"
      underline_char="-"
      separator="  "
      color_blocks="off"
      block_range=(0 15) # Colorblocks

      # Colors for custom colorblocks
      magenta="\033[1;35m"
      green="\033[1;32m"
      white="\033[1;37m"
      blue="\033[1;34m"
      red="\033[1;31m"
      black="\033[1;40;30m"
      yellow="\033[1;33m"
      cyan="\033[1;36m"
      reset="\033[0m"
      bgyellow="\033[1;43;33m"
      bgwhite="\033[1;47;37m"
      cl0="''${reset}"
      cl1="''${magenta}"
      cl2="''${green}"
      cl3="''${white}"
      cl4="''${blue}"
      cl5="''${red}"
      cl6="''${yellow}"
      cl7="''${cyan}"
      cl8="''${black}"
      cl9="''${bgyellow}"
      cl10="''${bgwhite}"

      block_width=4
      block_height=1

      bar_char_elapsed="-"
      bar_char_total="="
      bar_border="on"
      bar_length=15
      bar_color_elapsed="distro"
      bar_color_total="distro"

      cpu_display="on"
      memory_display="on"
      battery_display="on"
      disk_display="on"

      image_backend="kitty"
      image_source="${self}/assets/images/nixos-logo.png"
      image_size="250px"
      image_loop="off"

      aascii_distro="auto"
      ascii_colors=(distro)
      ascii_bold="on"

      crop_mode="normal"
      crop_offset="center"

      gap=2

      yoffset=0
      xoffset=0

      stdout="off"
    '';
  };
}
