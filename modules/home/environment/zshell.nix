{lib, config, self, ...}: {
  options = {
    zshConfig.enable = lib.mkEnableOption "enables my zsh configuration";
  };
  config = lib.mkIf config.zshConfig.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zsh = {
      enable = true;

      sessionVariables = {
        SOUNDS_ENABLED = "1";
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";
        VISUAL = "nvim";
        LANG = "en_US.UTF-8";
        BROWSER = "firefox";
        FLAKEPATH = "$HOME/.sysflake";
      };

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "fzf"];
      };

      enableCompletion = true;
      history = {
        path = "$HOME/.zsh_history";
        save = 10000;
        size = 10000;
        share = true;
      };

      #git
      "ga" = "playshellsound ${self}/assets/sound/gitadd.wav; git add";
      gco = "gitcheckout_sfx";
      gcomm = "gitcommit_sfx";
      gpush = "gitpush_sfx";
      gpull = "gitpull_sfx";
      greb = "gitrebase_sfx";
    };
    initExtra = ''
      playshellsound() {
        if [ $# -ne 1 ]; then
          echo "Usage: playshellsound <path/to/sound>"
          return 1
        fi
        if ! scheck; then
          return 0
        else
          runbg aplay "$1"
        fi
      }
      gitcheckout_sfx() {
        if git checkout "$@"; then
          playshellsound ${self}/assets/sound/gitcheckout.wav
          return 0
        else
          playshellsound ${self}/assets/sound/error.wav
          return 1
        fi
      }
      gitrebase_sfx() {
        if git rebase "$@"; then
          playshellsound ${self}/assets/sound/gitrebase.wav
          return 0
        else
          playshellsound ${self}/assets/sound/error.wav
          return 1
        fi
      }
      gitcommit_sfx() {
        if git commit "$@"; then
          playshellsound ${self}/assets/sound/gitcommit.wav
          return 0
        else
          playshellsound ${self}/assets/sound/error.wav
          return 1
        fi
      }
      gitpush_sfx() {
        if git push "$@"; then
          playshellsound ${self}/assets/sound/gitpush.wav
          return 0
        else
          playshellsound ${self}/assets/sound/error.wav
          return 1
        fi
      }
      gitpull_sfx() {
        if git pull "$@"; then
          playshellsound ${self}/assets/sound/gitpull.wav
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
          playshellsound /nix/store/7a9w7np3qrvmzxjbs7xj05qq2yccgfsj-source/assets/sound/cd.wav
          return 0
        }
        if [ ! -e $HOME/.zsh_history ]; then
          touch $HOME/.zsh_history
          chmod 600 $HOME/.zsh_history
        fi
        setopt APPEND_HISTORY     # Append history to the history file (don't overwrite)
        setopt INC_APPEND_HISTORY # Append to the history file incrementally
        setopt SHARE_HISTORY      # Share history between all zsh sessions

        sessionVariables = {
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
        type starship_zle-keymap-select >/dev/null || \
        {
          eval "$(starship init zsh)"
        }
        unalias ls
        clear
        splash
        playshellsound ${self}/assets/sound/sh-source.wav
        [ ! -f $FLAKEPATH/flake.nix ] && echo "WARNING: flake.nix not found at \$FLAKEPATH. Shell aliases for editing config files won't work correctly!" && echo "Edit the FLAKEPATH session variable in zshell.nix to point to the path where you saved the system configuration flake."
      '';
    };
  };
}
