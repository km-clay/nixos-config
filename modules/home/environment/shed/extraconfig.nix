{ pkgs, ... }:
{
  programs.shed = {
    extraPostConfig = /* bash */ ''
      # stat line palette
      declare -A BG=(
        [mode]=33
        [path]=39
        [git]=76
        [time]="33;33;33"
        [stat]=18
      )

      declare -A FG=(
        [mode]=15
        [path]=15
        [git]=15
        [time]=15
        [stat]=18
      )

      if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        export EDITOR="neovide" SUDO_EDITOR="neovide" VISUAL="neovide"
      else
        export EDITOR="nvim" SUDO_EDITOR="nvim" VISUAL="nvim"
      fi

      SHED_EXEC_WRAPPERS+=("invoke")

      alias fds='lsfd -p $$ -Q "FD >=0" -o FD,XMODE,TYPE,NAME'

      stash --save "commit"     $'gitcommit_sfx -m ""' 18
      stash --save "if_stmt"    $'if :; then\n\t:\nfi' 0
      stash --save "while_loop" $'while :; do\n\t:\ndone' 0
      stash --save "until_loop" $'until :; do\n\t:\ndone' 0
      stash --save "for_loop"   $'for : in :; do\n\t:\ndone' 0
      stash --save "case_stmt"  $'case : in\n\t*)\n\t\t:\n\t;;\nesac' 0
      stash --save "func_def"   $':() {\n\t:\n}' 0

      if [ "''${STATLINE_GIT:-0}" -eq 1 ]; then
        git_stat_line_update
      else
        export GIT_STAT_LINE=""
      fi

      if [ -n "$LS_COLORS" ]; then unset LS_COLORS; fi

      if [ -f "$HOME/.shedrc_mut" ]; then
        source "$HOME/.shedrc_mut"
      fi

      backup_history
    '';
  };
}
