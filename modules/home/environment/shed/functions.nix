{ self, pkgs, ... }:
let
  shellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  color-commit = "${pkgs.myScripts.color-commit}/bin/color-commit";
  sndpath = "${self}/assets/sound";
in
{
  programs.shed = {
    functions = {
      prompt_topline = /* bash */ ''
        local user_and_host="\e[0m\e[1m$USER\e[1;36m@\e[1;31m$HOST\e[0m"
        local mode_text="$(prompt_mode)"
        echo -n "\e[1;34m┏━ $user_and_host $mode_text\n"
      '';

      prompt_mode = /* bash */ ''
        local mode=""
        local normal_fg='\e[0m\e[30m\e[1;43m'
        local normal_bg='\e[0m\e[33m'
        local insert_fg='\e[0m\e[30m\e[1;46m'
        local insert_bg='\e[0m\e[36m'
        local command_fg='\e[0m\e[30m\e[1;42m'
        local command_bg='\e[0m\e[32m'
        local visual_fg='\e[0m\e[30m\e[1;45m'
        local visual_bg='\e[0m\e[35m'
        local replace_fg='\e[0m\e[30m\e[1;41m'
        local replace_bg='\e[0m\e[31m'
        local search_fg='\e[0m\e[30m\e[1;47m'
        local search_bg='\e[0m\e[39m'
        local complete_fg='\e[0m\e[30m\e[1;47m'
        local complete_bg='\e[0m\e[39m'


        case "$SHED_VI_MODE" in
          "NORMAL")
            mode="$normal_bg''${normal_fg}NORMAL$normal_bg\e[0m"
          ;;
          "INSERT")
            mode="$insert_bg''${insert_fg}INSERT$insert_bg\e[0m"
          ;;
          "COMMAND")
            mode="$command_bg''${command_fg}COMMAND$command_bg\e[0m"
          ;;
          "VISUAL")
            mode="$visual_bg''${visual_fg}VISUAL$visual_bg\e[0m"
          ;;
          "REPLACE")
            mode="$replace_bg''${replace_fg}REPLACE$replace_bg\e[0m"
          ;;
          "VERBATIM")
            mode="$replace_bg''${replace_fg}VERBATIM$replace_bg\e[0m"
          ;;
          "COMPLETE")
            mode="$complete_bg''${complete_fg}COMPLETE$complete_bg\e[0m"
          ;;
          "SEARCH")
            mode="$search_bg''${search_fg}SEARCH$search_bg\e[0m"
          ;;
          *)
            mode=""
          ;;
        esac

        echo -en "$mode\n"
      '';

      prompt_stat_line = /* bash */ ''
        local last_exit_code="$?"
        local last_cmd_status
        local last_cmd_runtime
        if [ "$last_exit_code" -eq "0" ]; then
          last_cmd_status="\e[1;32m"
        else
          last_cmd_status="\e[1;31m"
        fi
        local last_runtime_raw="$(echo -p "\t")"
        if [ -z "$last_runtime_raw" ]; then
          return 0
        else
          last_cmd_runtime="\e[1;38;2;249;226;175m󰔛 ''${last_cmd_status}$(echo -p "\T")\e[0m"
        fi

        echo -n "\e[1;34m┃ $last_cmd_runtime\e[0m\n"
      '';

      prompt_git_line = /* bash */ ''
        local status="$(git status --porcelain -b 2>/dev/null)" || return

        local branch="" gitsigns="" ahead=0 behind=0
        local header="''${status%%$'\n'*}"

        branch="''${header#\#\# }"
        branch="''${branch%%...*}"
        case "$header" in
            *ahead*)  ahead="''${header#*ahead }"; ahead="''${ahead%%[],]*}"; gitsigns="''${gitsigns}↑" ;;
        esac
        case "$header" in
            *behind*) behind="''${header#*behind }"; behind="''${behind%%[],]*}"; gitsigns="''${gitsigns}↓" ;;
        esac

        case "$status" in
            *$'\n'" "[MAR]*) gitsigns="''${gitsigns}!" ;;
        esac
        case "$status" in
            *$'\n'"??"*) gitsigns="''${gitsigns}?" ;;
        esac
        case "$status" in
            *$'\n'" "[D]*) gitsigns="''${gitsigns}" ;;
        esac
        case "$status" in
            *$'\n'[MADR]*) gitsigns="''${gitsigns}+" ;;
        esac

        local diff="$(git diff --shortstat 2>/dev/null)"

        local diff="$(git diff --shortstat 2>/dev/null)"
        local changed="" add="" del=""
        if [ -n "$diff" ]; then
            changed="''${diff%% file*}"; changed="''${changed##* }"
            case "$diff" in
                *insertion*) add="''${diff#*, }"; add="''${add%% *}" ;;
            esac
            case "$diff" in
                *deletion*) del="''${diff% deletion*}"; del="''${del##* }" ;;
            esac
        fi

        if [ -n "$gitsigns" ] || [ -n "$branch" ]; then
            [ -n "$gitsigns" ] && gitsigns="\e[1;31m[$gitsigns]"
            [ -n "$changed" ] && [ "$changed" -gt 0 ] && changed="\e[1;34m~$changed \e[0m"
            [ -n "$add" ] && [ "$add" -gt 0 ] && add="\e[1;32m+$add \e[0m"
            [ -n "$del" ] && [ "$del" -gt 0 ] && del="\e[1;31m-$del\e[0m"
            echo -n "\e[1;34m┃ \e[1;35m $branch$gitsigns\e[0m $changed$add$del\n"
        fi
      '';

      prompt_jobs_line = /* bash */ ''
        local job_count="$(echo -p '\j')"
        if [ "$job_count" -gt 0 ]; then
          echo -n "\e[1;34m┃ \e[1;33m󰒓 $job_count job(s) running\e[0m\n"
        fi
      '';

      prompt_ssh_line = /* bash */ ''
        local ssh_server="$(echo $SSH_CONNECTION | cut -f3 -d' ')"
        [ -n "$ssh_server" ] && echo -n "\e[1;34m┃ \e[1;39m🌐 $ssh_server\e[0m\n"
        return 0
      '';

      prompt_pwd_line = /* bash */ ''
        echo -p "\e[1;34m┣━━ \e[1;36m\W\e[1;32m/"
      '';

      prompt_dollar_line = /* bash */ ''
        local dollar="$(echo -p "\$ ")"
        local dollar="$(echo -e "\e[1;32m$dollar\e[0m")"
        echo -n "\e[1;34m┗━ $dollar "
      '';

      prompt = /* bash */ ''
        local statline="$(prompt_stat_line)"
        local topline="$(prompt_topline)"
        local jobsline="$(prompt_jobs_line)"
        local sshline="$(prompt_ssh_line)"
        local pwdline="$(prompt_pwd_line)"
        local dollarline="$(prompt_dollar_line)"
        local prompt="$topline$statline$PROMPT_GIT_LINE$jobsline$sshline$pwdline\n$dollarline"

        echo -en "$prompt"
      '';

      shed_ver = ''
        shed --version
      '';

      encrypt = /* bash */ ''
        if [ -z "$1" ]; then
          echo "Usage: encrypt <text> [recipient]"
          return 1
        fi
        if [ -z "$2" ]; then
          gpg --encrypt --armor -r "$1"
        else
          echo "$1" | gpg --encrypt --armor -r "$2"
        fi
      '';
      decrypt = /* bash */ ''
        if [ -z "$1" ]; then
          gpg --decrypt --quiet 2>/dev/null
        else
          echo "$1" | gpg --decrypt --quiet
        fi
      '';

      viflake = /* bash */ ''
        filename="$(upfind flake.nix)"
        if [ -n "$filename" ]; then
          nvim "$filename"
        else
          echo "No flake.nix found in this directory or any parent directories."
          return 1
        fi
      '';

      upfind = /* bash */ ''
        until [ "$#" -eq 0 ]; do
          filename="$1"
          (
            until [ -f "./$filename" ]; do
              builtin cd ..
              if [ "$PWD" = "/" ]; then
                echo "upsearch: failed to find file '$filename' in this directory or any parent directories." 1>&2
                break
              fi
            done
            if [ -f "./$filename" ]; then
              realpath "./$filename"
            fi
          )
          shift 1
        done
      '';

      nvim = /* bash */ ''
        ${shellsound} ${sndpath}/nvim.wav
        command nvim "$@"
      '';
      neovide = /* bash */ ''
        ${shellsound} ${sndpath}/nvim.wav
        command neovide "$@"
      '';
      grimblast = /* bash */ ''
        if command grimblast "$@"; then
          ${shellsound} ${sndpath}/screenshot.wav
        fi
      '';
      gitcheckout_sfx = /* bash */ ''
        if git checkout "$@"; then
          ${shellsound} ${sndpath}/gitcheckout.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      '';
      gitrebase_sfx = /* bash */ ''
        if git rebase "$@"; then
          ${shellsound} ${sndpath}/gitrebase.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      '';
      gitcommit_sfx = /* bash */ ''
        local output="$(git commit "$@")"
        if [ "$?" -eq "0" ]; then
          ${shellsound} ${sndpath}/gitcommit.wav
          echo "$output" | ${color-commit}
          return 0
        else
          ${shellsound} ${sndpath}/error.wav
          echo "$output"
          return 1
        fi
      '';
      gitpush_sfx = /* bash */ ''
        if git push "$@"; then
          ${shellsound} ${sndpath}/gitpush.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      '';
      gitpull_sfx = /* bash */ ''
        if git pull "$@"; then
          ${shellsound} ${sndpath}/gitpull.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      '';

      ls = /* bash */ ''
        eza -1 --group-directories-first --icons "$@"
      '';

      mkcd = /* bash */ ''
        command mkdir -p "$1" && builtin cd "$1"
      '';

      cd = /* bash */ ''
        eza -1 --group-directories-first --icons "$@" 2> /dev/null
        builtin cd "$@"
      '';

      hyprsock = /* bash */ ''
        socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
      '';

      vipe = /* bash */ ''
        local tmp=$(mktemp)
        $EDITOR "$tmp" -R - >/dev/tty </dev/tty
        cat "$tmp"
        rm "$tmp"
      '';

      reboot = /* bash */ ''
        echo "Really? enter = yes"
        read_key -v res
        case "$res" in
          "<Enter>")
            command reboot
          ;;
          *)
            echo "Canceling reboot."
          ;;
        esac
      '';

      h_pager = /* bash */ ''
        TERM=xterm less
      '';

      shlvl = "echo $SHLVL";
    };
  };
}
