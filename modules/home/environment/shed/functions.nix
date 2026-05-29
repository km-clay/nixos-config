{ self, pkgs, ... }:
let
  color-commit = "${pkgs.myScripts.color-commit}/bin/color-commit";
in
{
  programs.shed = {
    functions = {
      prompt_topline = /* bash */ ''
        local user_and_host="\e[0m\e[1m$USER\e[1;36m@\e[1;31m$HOST\e[0m"
        echo -n "\e[1;34m┏━ $user_and_host\n"
      '';

      shed_ver = /* bash */ ''
        echo -en "\e[1;36m\$$(version -v)"
      '';

      __mod = /* bash */ ''
        local key="$1" content="$2" sep="$3"
        __mod_dyn "''${BG[$key]}" "''${FG[$key]}" "$content" "$sep"
      '';

      __mod_dyn = /* bash */ ''
        local bg="$1" fg="$2" content="$3" sep="$4"
        [[ -z "$content" ]] && return
        if [[ -n "$__PREV_BG" ]]; then
          __emit_fg "$__PREV_BG"; __emit_bg "$bg"
          echo -n "$sep"
        fi
        __emit_bg "$bg"; __emit_fg "$fg"
        echo -n " $content "
        __PREV_BG="$bg"
      '';

      __mod_right = /* bash */ ''
        __mod_dyn_right "''${BG[$1]}" "''${FG[$1]}" "$2" "$LINE_SEP_RIGHT"
      '';

      __mod_dyn_right = /* bash */ ''
        local bg="$1" fg="$2" content="$3" sep="$4"
        [[ -z "$content" ]] && return
        if [[ -n "$__PREV_BG" ]]; then
          # mid chain
          __emit_fg "$bg"; __emit_bg "$__PREV_BG"
          echo -n "$sep"
        else
          __emit_fg "$bg"
          echo -en "\e[49m$sep"
        fi
        __emit_bg "$bg"; __emit_fg "$fg"
        echo -en "\e[1m $content "
        __PREV_BG="$bg"
      '';
      __emit_bg = /* bash */ ''
        local val="$1"
        if [[ "$val" == *";"* ]]; then
          echo -en "\e[48;2;''${val}m"
        else
          echo -en "\e[48;5;''${val}m"
        fi
      '';
      __emit_fg = /* bash */ ''
        local val="$1"
        if [[ "$val" == *";"* ]]; then
          echo -en "\e[38;2;''${val}m"
        else
          echo -en "\e[38;5;''${val}m"
        fi
      '';

      emit_mode = /* bash */ ''
        local bg fg=0
        case "$SHED_EDIT_MODE" in
          NORMAL)                 bg=3 ;;
          INSERT|"(insert)")      bg=6 ;;
          COMMAND)                bg=2 ;;
          VISUAL)                 bg=5 ;;
          REPLACE|VERBATIM|EMACS) bg=1 ;;
          SEARCH|REMOTE|COMPLETE) bg=7 ;;
          *) return ;;
        esac
        echo -en "\e[1m"
        __mod_dyn "$bg" "$fg" "$SHED_EDIT_MODE" "$LINE_SEP_LEFT" "1"
      '';

      cmd_status_line = /* bash */ ''
        local last_cmd_stat
        local last_cmd_runtime
        if [[ "$last_exit" == "0" ]]; then
          last_cmd_stat="\e[1;32m"
        else
          last_cmd_stat="\e[1;31m"
        fi
        local last_runtime="$(echo -p "\t")"
        if [[ -z "$last_runtime" ]]; then
          return 0
        else
          last_cmd_runtime="\e[1;38;2;249;226;175m󰔛 ''${last_cmd_stat}$(echo -p "\T")\e[39m"
        fi
        echo -en "$last_cmd_runtime \e[1m-> [''${last_cmd_stat}''${last_exit}\e[39m]"
      '';

      git_stat_line = /* bash */ ''
        if [[ -n "$GIT_STAT_DIR" ]] && ! _="''${PWD#$GIT_STAT_DIR}"; then
          export GIT_STAT_LINE=""
          export GIT_STAT_DIR=""
          return
        fi
        if [[ -z "$GIT_STAT_LINE" ]]; then
          if [[ "''${STATLINE_GIT:-0}" -eq 1 ]]; then
            git_stat_line_update
          fi
        fi
        echo -en "$GIT_STAT_LINE"
      '';

      git_stat_line_update = /* bash */ ''
        local status="$(git status --porcelain -b 2>/dev/null)" || return
        local diff="$(git diff --shortstat 2>/dev/null)"
        local cache_key="$status"$'\n'"$diff"
        if [[ -n "$LAST_DIFF" ]] && [[ "$LAST_DIFF" == "$cache_key" ]]; then
          # its the same as last time. lets not do all this stuff actually
          return 0
        fi
        LAST_DIFF="$cache_key"

        local branch="" gitsigns="" ahead=0 behind=0
        local header="''${status%%$'\n'*}"

        # hope you like parameter expansion
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

        local changed="" add="" del=""
        if [ -n "$diff" ]; then
          changed="''${diff%% file*}"; changed="''${changed##* }"
          case "$diff" in *insertion*) add="''${diff#*, }"; add="''${add%% *}" ;; esac
          case "$diff" in *deletion*) del="''${diff% deletion*}"; del="''${del##* }" ;; esac
        fi

        if [[ -n "$branch" ]]; then
          local out=" $branch"
          [[ -n "$gitsigns" ]] && out="$out\e[38;5;9m[$gitsigns]"
          [[ -n "$changed" ]] && [[ "$changed" -gt 0 ]] && out="$out \e[38;5;12m~$changed\e[39m"
          [[ -n "$add" ]] && [[ "$add" -gt 0 ]] && out="$out \e[38;5;10m+$add\e[39m"
          [[ -n "$del" ]] && [[ "$del" -gt 0 ]] && out="$out \e[38;5;9m-$del\e[39m"
          export GIT_STAT_LINE="\e[1;38;5;13m$out"
          export GIT_STAT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"
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
        echo -n "\e[1;34m┗━ $dollar"
      '';

      prompt = /* bash */ ''
        local topline="$(prompt_topline)"
        local jobsline="$(prompt_jobs_line)"
        local sshline="$(prompt_ssh_line)"
        local pwdline="$(prompt_pwd_line)"
        local dollarline="$(prompt_dollar_line)"
        local prompt="\n$topline$jobsline$sshline$pwdline\n$dollarline"

        echo -en "$prompt"
      '';

      stat_line_left = /* bash */ ''
        local last_exit="$?"
        __PREV_BG=""
        emit_mode && \
        __mod time "$(git_stat_line)" $LINE_SEP_LEFT && \
        __mod stat "$(cmd_status_line)" $LINE_SEP_LEFT && \
        __cap $LINE_SEP_LEFT "18"

      '';
      __cap = /* bash */ ''
        local sep="$1" reset="$2"
        if [ -n "$__PREV_BG" ]; then
          if [ -n "$reset" ]; then
            __emit_bg "$reset"
          else
            echo -en "\e[49m"
          fi
          __emit_fg "$__PREV_BG"
          echo -n "$sep"
        fi
        __PREV_BG="$reset"
      '';

      stat_line_right = /* bash */ ''
        __PREV_BG="18"
        __mod_right time "$(shed_ver)"
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
        until [[ "$#" -eq 0 ]]; do
          target="$1"
          (
            until [[ -e "./$target" ]]; do
              builtin cd ..
              if [[ "$PWD" == "/" ]]; then
                echo "upsearch: failed to find file '$target' in this directory or any parent directories." 1>&2
                exit 1
              fi
            done
            realpath "./$target"
          )
          if [[ "$?" -ne 0 ]]; then
            return 1
          fi
          shift 1
        done
      '';

      nvim = /* bash */ ''
        playshellsound nvim.wav
        command nvim "$@"
      '';
      neovide = /* bash */ ''
        playshellsound nvim.wav
        command neovide "$@"
      '';
      grimblast = /* bash */ ''
        if command grimblast "$@"; then
          playshellsound screenshot.wav
        fi
      '';
      gitcheckout_sfx = /* bash */ ''
        if git checkout "$@"; then
          playshellsound gitcheckout.wav
        else
          status="$?"
          playshellsound error.wav
          return $status
        fi
      '';
      gitrebase_sfx = /* bash */ ''
        if git rebase "$@"; then
          playshellsound gitrebase.wav
        else
          status="$?"
          playshellsound error.wav
          return $status
        fi
      '';
      gitcommit_sfx = /* bash */ ''
        local output="$(git commit "$@")"
        if [ "$?" -eq "0" ]; then
          playshellsound gitcommit.wav
          echo "$output" | ${color-commit}
          return 0
        else
          playshellsound error.wav
          echo "$output"
          return 1
        fi
      '';
      gitpush_sfx = /* bash */ ''
        if git push "$@"; then
          playshellsound gitpush.wav
        else
          status="$?"
          playshellsound error.wav
          return $status
        fi
      '';
      gitpull_sfx = /* bash */ ''
        if git pull "$@"; then
          playshellsound gitpull.wav
        else
          status="$?"
          playshellsound error.wav
          return $status
        fi
      '';

      ls = /* bash */ ''
        playshellsound ls.wav
        eza -1 --group-directories-first --icons "$@"
      '';

      mkcd = /* bash */ ''
        command mkdir -p "$1" && builtin cd "$1"
      '';

      cd = /* bash */ ''
        playshellsound cd.wav
        eza -1 --group-directories-first --icons "$@" 2> /dev/null
        builtin cd "$@"
      '';

      hyprsock = /* bash */ ''
        socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
      '';

      reboot = /* bash */ ''
        echo "Really? enter = yes"
        readkey -v res
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
        TERM=xterm less "$@"
      '';

      lvl = "echo $SHLVL";
    };
  };
}
