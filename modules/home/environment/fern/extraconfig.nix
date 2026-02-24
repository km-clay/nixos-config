{ lib, config, self, pkgs, ... }:
let
  shellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  color-commit = "${pkgs.myScripts.color-commit}/bin/color-commit";
  sndpath = "${self}/assets/sound";
in
{
  programs.fern = {
    settings.extraPreConfig = ''
      prompt_topline() {
        local last_cmd_status
        local last_cmd_runtime
        if [ "$?" -eq "0" ]; then
          last_cmd_status="\e[1;32m\e[0m"
        else
          last_cmd_status="\e[1;31m\e[0m"
        fi
        local user_and_host="\e[1m$USER\e[1;36m@\e[1;31m$HOST\e[0m"
        local last_runtime_raw="$(echo -p "\t")"
        if [ -z "$last_runtime_raw" ]; then
          last_cmd_runtime=""
          last_cmd_status=""
        else
          last_cmd_runtime="\e[1;38;2;249;226;175m󰔛 $(echo -p "\T")\e[0m"
        fi
        echo -n "$user_and_host $last_cmd_runtime $last_cmd_status\n"
      }

      prompt_midline() {
        git rev-parse --is-inside-work-tree > /dev/null 2>&1 || return

        local gitsigns
        local status="$(git status --porcelain 2>/dev/null)"

        [ -n "$status" ] && echo "$status" | command grep -q '^ [MADR]' && gitsigns="$gitsigns!"
        [ -n "$status" ] && echo "$status" | command grep -q '^??' && gitsigns="$gitsigns?"
        [ -n "$status" ] && echo "$status" | command grep -q '^[MADR]' && gitsigns="$gitsigns+"

        local ahead="$(git rev-list --count @{upstream}..HEAD 2>/dev/null)"
        local behind="$(git rev-list --count HEAD..@{upstream} 2>/dev/null)"
        [ $ahead -gt 0 ] && gitsigns="$gitsigns↑"
        [ $behind -gt 0 ] && gitsigns="$gitsigns↓"

        local branch="$(git branch --show-current 2>/dev/null)"

        if [ -n "$gitsigns" ] || [ -n "$branch" ]; then
          if [ -n "$gitsigns" ]; then
            gitsigns="\e[1;31m[$gitsigns]"
          fi
          echo -n "\e[0mon \e[1;35m ''${branch}$gitsigns\e[0m\n"
        fi
      }

      prompt_botline() {
        echo -p "\e[1;36m\W\e[1;32m/"
      }

      prompt() {
        local top="$(prompt_topline)"
        local mid="$(prompt_midline)"
        local bot="$(prompt_botline)"
        local dollar="$(echo -p "\$ ")"
        local dollar="$(echo -e "\e[1;32m$dollar\e[0m")"
        local prompt="$top$mid$bot\n$dollar"

        echo -en "$prompt"
      }

      export PS1="\n\!prompt "
    '';
    settings.extraPostConfig = ''
      encrypt() {
        if [ -z "$1" ]; then
          echo "Usage: encrypt <text> [recipient]"
          return 1
        fi
        if [ -z "$2" ]; then
          gpg --encrypt --armor -r "$1"
        else
          echo "$1" | gpg --encrypt --armor -r "$2"
        fi
      }
      decrypt() {
        if [ -z "$1" ]; then
          gpg --decrypt --quiet 2>/dev/null
        else
          echo "$1" | gpg --decrypt --quiet
        fi
      }

      viflake() {
        (
          while ! [ -f ./flake.nix ]; do
            builtin cd ..
            if [ "$PWD" = "/" ]; then
              echo "No flake.nix found in this directory or any parent directories."
              return 1
            fi
          done
          nvim ./flake.nix
        )
      }

      nvim() {
        ${shellsound} ${sndpath}/nvim.wav
        command nvim "$@"
      }
      neovide() {
        ${shellsound} ${sndpath}/nvim.wav
        command neovide "$@"
      }
      grimblast() {
        if command grimblast "$@"; then
          ${shellsound} ${sndpath}/screenshot.wav
        fi
      }
      gitcheckout_sfx() {
        if git checkout "$@"; then
          ${shellsound} ${sndpath}/gitcheckout.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      }
      gitrebase_sfx() {
        if git rebase "$@"; then
          ${shellsound} ${sndpath}/gitrebase.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      }
      gitcommit_sfx() {
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
      }
      gitpush_sfx() {
        if git push "$@"; then
          ${shellsound} ${sndpath}/gitpush.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      }
      gitpull_sfx() {
        if git pull "$@"; then
          ${shellsound} ${sndpath}/gitpull.wav
        else
          ${shellsound} ${sndpath}/error.wav
        fi
      }

      ls() {
        eza -1 --group-directories-first --icons "$@"
        ${shellsound} ${sndpath}/ls.wav
      }

      mkcd() {
        command mkdir -p "$1" && builtin cd "$1"
      }

      cd() {
        eza -1 --group-directories-first --icons "$@" 2> /dev/null
        builtin cd "$@"
        ${shellsound} ${sndpath}/cd.wav
      }

      vipe() {
        local tmp=$(mktemp)
        $EDITOR "$tmp" >/dev/tty </dev/tty
        cat "$tmp"
        rm "$tmp"
      }

      if [ "$0" = "-fern" ]; then
        ${shellsound} $FLAKEPATH/assets/sound/login.wav
      fi
    '';
  };
}
