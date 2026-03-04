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
        echo -n "\e[1;34m┏━ $user_and_host\n"
      '';

      prompt_stat_line = /* bash */ ''
        local last_exit_code="$?"
        local last_cmd_status
        local last_cmd_runtime
        if [ "$last_exit_code" -eq "0" ]; then
          last_cmd_status="\e[1;32m\e[0m"
        else
          last_cmd_status="\e[1;31m\e[0m"
        fi
        local last_runtime_raw="$(echo -p "\t")"
        if [ -z "$last_runtime_raw" ]; then
          return 0
        else
          last_cmd_runtime="\e[1;38;2;249;226;175m󰔛 $(echo -p "\T")\e[0m"
        fi

        echo -n "\e[1;34m┃ $last_cmd_runtime ($last_cmd_status)\n"
      '';

      prompt_git_line = /* bash */ ''
        git rev-parse --is-inside-work-tree > /dev/null 2>&1 || return

        local gitsigns
        local status="$(git status --porcelain 2>/dev/null)"
        local branch="$(git branch --show-current 2>/dev/null)"

        [ -n "$status" ] && echo "$status" | command grep -q '^ [MADR]' && gitsigns="$gitsigns!"
        [ -n "$status" ] && echo "$status" | command grep -q '^??' && gitsigns="$gitsigns?"
        [ -n "$status" ] && echo "$status" | command grep -q '^[MADR]' && gitsigns="$gitsigns+"

        local ahead="$(git rev-list --count @{upstream}..HEAD 2>/dev/null)"
        local behind="$(git rev-list --count HEAD..@{upstream} 2>/dev/null)"
        [ $ahead -gt 0 ] && gitsigns="$gitsigns↑"
        [ $behind -gt 0 ] && gitsigns="$gitsigns↓"

        local diff="$(git diff --shortstat)"
        local add=""
        local del=""
        local changed=""
        i=0
        while read -d "," part; do
          if [ $i -ge 3 ]; then break; fi
          case $i in
            0)
              changed="$(echo $part | cut -d' ' -f1)"
            ;;
            1)
              add="$(echo $part | cut -d' ' -f1)"
            ;;
            2)
              del="$(echo $part | cut -d' ' -f1)"
            ;;
          esac
          i=$(($i + 1))
        done < <(echo "$diff,")

        if [ -n "$gitsigns" ] || [ -n "$branch" ]; then
          if [ -n "$gitsigns" ]; then
            gitsigns="\e[1;31m[$gitsigns]"
          fi
          if [ -n "$changed" ] && [ "$changed" -gt 0 ]; then
            changed="\e[1;34m~$changed \e[0m"
          fi
          if [ -n "$add" ] && [ "$add" -gt 0 ]; then
            add="\e[1;32m+$add \e[0m"
          fi
          if [ -n "$del" ] && [ "$del" -gt 0 ]; then
            del="\e[1;31m-$del\e[0m"
          fi
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
        local gitline="$(prompt_git_line)"
        local jobsline="$(prompt_jobs_line)"
        local sshline="$(prompt_ssh_line)"
        local pwdline="$(prompt_pwd_line)"
        local dollarline="$(prompt_dollar_line)"
        local prompt="$topline$statline$gitline$jobsline$sshline$pwdline\n$dollarline"

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
        ${shellsound} ${sndpath}/ls.wav
      '';

      mkcd = /* bash */ ''
        command mkdir -p "$1" && builtin cd "$1"
      '';

      cd = /* bash */ ''
        eza -1 --group-directories-first --icons "$@" 2> /dev/null
        builtin cd "$@"
        ${shellsound} ${sndpath}/cd.wav
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
    };
  };
}
