{self, ...}: {
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

    autosuggestion = {
      enable = true;
      highlight = "fg=#4C566A,underline";
    };

    shellAliases = {
      grep = "grep --color=auto";
      yazi = "y";
      vi = "nvim";
      mv = "mv -v";
      cp = "cp -vr";
      gt = "gtrash";
      gtp = "gtrash put";
      grub-update = "sudo grub-mkconfig -o /boot/grub/grub.cfg";
      sr = "source ~/.zshrc";
      ".." = "cd ..";
      rm = "echo 'use \"gtp\" instead'";
      psg = "ps aux | grep -v grep | grep -i -e VSZ -e";
      mkdir = "mkdir -p";
      pk = "pkill -9 -f";
      zrc = "nvim ${self}/modules/home/environment/zshell.nix";
      svcu = "systemctl --user";
      svc = "sudo systemctl";
      viflake = "nvim flake.nix";
      hyprconf = "yazi ${self}/modules/home/hyprland && popd &> /dev/null";
      hmconf = "yazi ${self}/modules/home/ && popd &> /dev/null";
      nixconf = "yazi ${self}/modules/sys/ && popd &> /dev/null";
      hostconf = "yazi ${self}/hosts && popd &> /dev/null";
      nvimcfg = "yazi ${self}/pkgs/nixvim/config && popd &> /dev/null";
    };
    initExtra = ''

      unalias ls
      ls() {
      	eza -1 --group-directories-first --icons "$@"
      	scheck && runbg aplay ${self}/assets/sound/ls.wav
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
      	export SOUNDS_ENABLED=0
      	eza -1 --group-directories-first --icons "$@"
      	builtin cd "$@" || exit
      	export SOUNDS_ENABLED=1
      	scheck && runbg aplay ${self}/assets/sound/cd.wav
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
      scheck && runbg aplay ${self}/assets/sound/sh-source.wav
    '';
  };
}
