{ lib, config, self, pkgs, ... }:

let
  shellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  sndpath = "${self}/assets/sound";
in
{
  options = {
    movOpts.envConfig.zshConfig.extraConfig.enable = lib.mkEnableOption "enables my extra shell configurations";
  };
  config = lib.mkIf config.movOpts.envConfig.zshConfig.extraConfig.enable {
    programs.zsh = {
      initExtra = ''
        build-drv() { # Put the derivation path in $RESULT instead of making a 'result' symlink
          RESULT=$(nix-build "$@" --no-link)
          if [ -z "$RESULT" ]; then
            return 1
          fi
          export RESULT
          echo "\$RESULT = $RESULT"
        }
        nvim() {
          ${shellsound} ${sndpath}/nvim.wav
          command nvim "$@"
        }
        alias vi="nvim"
        ssh() { # reverts ssh theme upon returning
          command ssh "$@"
          kitty_ssh_theme
        }
        kitty_ssh_theme() {
          if [ -n "$SSH_CONNECTION" ]; then
            kitty @ set-colors -a ~/.config/kitty/ssh-theme.conf
          else
            kitty @ set-colors -a ~/.config/kitty/default-theme.conf
          fi
        }
        grimblast() {
          if grimblast "$@"; then
            ${shellsound} ${sndpath}/screenshot.wav
          fi
        }
        gitcheckout_sfx() {
          if git checkout "$@"; then
            ${shellsound} ${sndpath}/gitcheckout.wav
            return 0
          else
            ${shellsound} ${sndpath}/error.wav
            return 1
          fi
        }
        gitrebase_sfx() {
          if git rebase "$@"; then
            ${shellsound} ${sndpath}/gitrebase.wav
            return 0
          else
            ${shellsound} ${sndpath}/error.wav
            return 1
          fi
        }
        gitcommit_sfx() {
          if git commit "$@"; then
            ${shellsound} ${sndpath}/gitcommit.wav
            return 0
          else
            ${shellsound} ${sndpath}/error.wav
            return 1
          fi
        }
        gitpush_sfx() {
          if git push "$@"; then
            ${shellsound} ${sndpath}/gitpush.wav
            return 0
          else
            ${shellsound} ${sndpath}/error.wav
            return 1
          fi
        }
        gitpull_sfx() {
          if git pull "$@"; then
            ${shellsound} ${sndpath}/gitpull.wav
            return 0
          else
            ${shellsound} ${sndpath}/error.wav
            return 1
          fi
        }
        unalias ls
        ls() {
          eza -1 --group-directories-first --icons "$@"
          ${shellsound} ${sndpath}/ls.wav
          return 0
        }

        mkcd() {
          mkdir -p "$1" && cd "$1"
        }

        y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }

        cd() {
          local prev_sounds_enabled="$SOUNDS_ENABLED"
          SOUNDS_ENABLED=0
          eza -1 --group-directories-first --icons "$@"
          SOUNDS_ENABLED=$prev_sounds_enabled
          builtin cd "$@"
          ${shellsound} /nix/store/7a9w7np3qrvmzxjbs7xj05qq2yccgfsj-source/assets/sound/cd.wav
          return 0
        }
        if [ ! -e $HOME/.zsh_history ]; then
          touch $HOME/.zsh_history
          chmod 600 $HOME/.zsh_history
        fi
        setopt APPEND_HISTORY     # Append history to the history file (don't overwrite)
        setopt INC_APPEND_HISTORY # Append to the history file incrementally
        setopt SHARE_HISTORY      # Share history between all zsh sessions

        setopt CORRECT
        setopt NO_NOMATCH
        setopt LIST_PACKED
        setopt ALWAYS_TO_END
        setopt GLOB_COMPLETE
        setopt COMPLETE_ALIASES
        setopt COMPLETE_IN_WORD
        setopt AUTO_CD
        setopt AUTO_CONTINUE
        setopt LONG_LIST_JOBS
        setopt HIST_VERIFY
        setopt SHARE_HISTORY
        setopt HIST_IGNORE_SPACE
        setopt HIST_SAVE_NO_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt EXTENDED_GLOB
        setopt TRANSIENT_RPROMPT
        setopt INTERACTIVE_COMMENTS

        autoload -U compinit     # completion
        autoload -U terminfo     # terminfo keys
        zmodload -i zsh/complist # menu completion
        autoload -U promptinit   # prompt

        autoload -U up-line-or-beginning-search; zle -N up-line-or-beginning-search
        autoload -U down-line-or-beginning-search; zle -N down-line-or-beginning-search

        bindkey -v
        kitty_ssh_theme
        type starship_zle-keymap-select >/dev/null || \
        {
          eval "$(starship init zsh)"
        }
        ${shellsound} ${sndpath}/sh-source.wav
        [ ! -f $FLAKEPATH/flake.nix ] && echo "WARNING: flake.nix not found at \$FLAKEPATH. Shell aliases for editing config files won't work correctly!" && echo "Edit the FLAKEPATH session variable in zshell.nix to point to the path where you saved the system configuration flake."
      '';
    };
  };
}
