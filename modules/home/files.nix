{pkgs, scheme, lib, self, config, ... }:

# This folder is for programs that do not have existing configuration modules in NixOS.
# Basically a to-do list for stuff I need to write my own modules for.
let
  # Custom theme that activates in ssh
  ssh_base16 = "black-metal-venom";

  scheme_path = "${pkgs.base16-schemes}/share/themes/${ssh_base16}.yaml";
  scheme_string = builtins.readFile scheme_path;
  scheme_list = lib.splitString "\n" "${scheme_string}";
  colors = lib.filter (line: builtins.match "^ *base[0-9A-F]{2}: .*" line != null) scheme_list;
  ssh_scheme =
    lib.lists.foldl' (
      acc: line: let
        splitLine = lib.splitString ": " line;
        key = builtins.elemAt splitLine 0;
        value = builtins.elemAt splitLine 1;
        trimmedKey = lib.trim key;
        cleanValue_step1 = lib.splitString " " value;
        cleanValue_step2 = builtins.elemAt cleanValue_step1 0;
        cleanValue_final = builtins.substring 1 (builtins.stringLength cleanValue_step2 - 2) cleanValue_step2;
      in
        acc // {"${trimmedKey}" = cleanValue_final;}
    ) {}
    colors;
in
{
  options = {
    homeFiles.enable = lib.mkEnableOption "enables declared custom files";
  };
  config = {
    home.file = {
      ".config/neofetch/config.conf".text = ''
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

      ".config/kitty/default-theme.conf".text = ''
        background #${scheme.base00}
        foreground #${scheme.base05}
        selection_background #${scheme.base05}
        selection_foreground #${scheme.base00}
        url_color #${scheme.base04}
        cursor #${scheme.base05}
        active_border_color #${scheme.base03}
        inactive_border_color #${scheme.base01}
        active_tab_background #${scheme.base00}
        active_tab_foreground #${scheme.base05}
        inactive_tab_background #${scheme.base01}
        inactive_tab_foreground #${scheme.base04}
        tab_bar_background #${scheme.base01}

        # normal
        color0 #${scheme.base01}
        color1 #${scheme.base08}
        color2 #${scheme.base0B}
        color3 #${scheme.base0A}
        color4 #${scheme.base0D}
        color5 #${scheme.base0E}
        color6 #${scheme.base0C}
        color7 #${scheme.base05}

        # bright
        color8 #${scheme.base03}
        color9 #${scheme.base09}
        color10 #${scheme.base01}
        color11 #${scheme.base02}
        color12 #${scheme.base04}
        color13 #${scheme.base06}
        color14 #${scheme.base0F}
        color15 #${scheme.base07}
      '';
      ".config/kitty/ssh-theme.conf".text = ''
        background #${ssh_scheme.base00}
        foreground #${ssh_scheme.base05}
        selection_background #${ssh_scheme.base05}
        selection_foreground #${ssh_scheme.base00}
        url_color #${ssh_scheme.base04}
        cursor #${ssh_scheme.base05}
        active_border_color #${ssh_scheme.base03}
        inactive_border_color #${ssh_scheme.base01}
        active_tab_background #${ssh_scheme.base00}
        active_tab_foreground #${ssh_scheme.base05}
        inactive_tab_background #${ssh_scheme.base01}
        inactive_tab_foreground #${ssh_scheme.base04}
        tab_bar_background #${ssh_scheme.base01}

        # normal
        color0 #${ssh_scheme.base01}
        color1 #${ssh_scheme.base08}
        color2 #${ssh_scheme.base0B}
        color3 #${ssh_scheme.base0A}
        color4 #${ssh_scheme.base0D}
        color5 #${ssh_scheme.base0E}
        color6 #${ssh_scheme.base0C}
        color7 #${ssh_scheme.base05}

        # bright
        color8 #${ssh_scheme.base03}
        color9 #${ssh_scheme.base09}
        color10 #${ssh_scheme.base01}
        color11 #${ssh_scheme.base02}
        color12 #${ssh_scheme.base04}
        color13 #${ssh_scheme.base06}
        color14 #${ssh_scheme.base0F}
        color15 #${ssh_scheme.base07}
      '';
    };
  };
}
