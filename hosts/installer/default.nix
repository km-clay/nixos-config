{
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: let
  extraFigletFonts = pkgs.fetchFromGitHub {
    owner = "xero";
    repo = "figlet-fonts";
    rev = "master";
    sha256 = "sha256-dAs7N66D2Fpy4/UB5Za1r2qb1iSAJR6TMmau1asxgtY=";
  };
  toilet-extrafonts = pkgs.toilet.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs or [] ++ [extraFigletFonts];

    installPhase = ''
      make install PREFIX=$out
      mkdir -p $out/share/figlet
      cp -r ${extraFigletFonts}/* $out/share/figlet
    '';
  });
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.home-manager.nixosModules.home-manager
    ../../modules/sys/software/nixvim
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
    hostName = "mov-nixos-installer";
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nh
    nvd
    lolcat
    curl
    wget
    coreutils
    findutils
    zip
    unzip
    util-linux
    git
    btrfs-progs
    dosfstools
    parted
    bc
    pciutils
    usbutils
    toilet-extrafonts
  ];

  home-manager = {
    users.root = {
      programs.home-manager.enable = true;
      home= {
        stateVersion = "24.05";
        file = {
          "disko.nix".source = ./disko-ext4-singledisk.nix;
        };
      };
    };
  };

  services = {
    openssh.enable = true;
    dbus.enable = true;
  };

  programs = {
    zsh = {
    enable = true;

    ohMyZsh = {
      enable = true;
      plugins = ["git" "fzf"];
    };

    enableCompletion = true;

    histFile = "$HOME/.zsh_history";
    histSize = 10000;

    autosuggestions = {
      enable = true;
      highlightStyle = "fg=#4C566A,underline";
    };

    shellAliases = {
      grep = "grep --color=auto";
      vi = "nvim";
      mv = "mv -v";
      cp = "cp -vr";
      ".." = "cd ..";
      psg = "ps aux | grep -v grep | grep -i -e VSZ -e";
      mkdir = "mkdir -p";
      pk = "pkill -9 -f";
      svc = "sudo systemctl";
    };
    promptInit = ''
      bindkey -v
      type starship_zle-keymap-select >/dev/null || \
      {
      	eval "$(starship init zsh)"
      }
    '';
    setOptions = [
      "APPEND_HISTORY"
      "INC_APPEND_HISTORY"
      "SHARE_HISTORY"
      "CORRECT"
      "NO_NOMATCH"
      "LIST_PACKED"
      "ALWAYS_TO_END"
      "GLOB_COMPLETE"
      "COMPLETE_ALIASES"
      "COMPLETE_IN_WORD"
      "AUTO_CD"
      "AUTO_CONTINUE"
      "LONG_LIST_JOBS"
      "HIST_VERIFY"
      "SHARE_HISTORY"
      "HIST_IGNORE_SPACE"
      "HIST_SAVE_NO_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "EXTENDED_GLOB"
      "TRANSIENT_RPROMPT"
      "INTERACTIVE_COMMENTS"
    ];
    shellInit = ''
      export EDITOR="nvim"
      export SUDO_EDITOR="nvim"
      export VISUAL="nvim"
      export LANG="en_US.UTF-8"

      unalias ls
      ls() {
      	eza -1 --group-directories-first --icons "$@"
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
      }
      if [ ! -e $HOME/.zsh_history ]; then
      	touch $HOME/.zsh_history
      	chmod 600 $HOME/.zsh_history
      fi

      autoload -U compinit     # completion
      autoload -U terminfo     # terminfo keys
      zmodload -i zsh/complist # menu completion
      autoload -U promptinit   # prompt

      autoload -U up-line-or-beginning-search; zle -N up-line-or-beginning-search
      autoload -U down-line-or-beginning-search; zle -N down-line-or-beginning-search

      unalias ls
      clear
    '';
    };
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        right_format = "($custom)";

        format = lib.concatStrings [
          "($username)(bold white)($cmd_duration)($character)"
          "($git_branch)($git_status)($rust)($nix-shell)"
          "($directory)"
          "$line_break[ > ](bold #89b4fa)"
        ];

        username = {
          show_always = true;
          style_user = "bold white";
          format = "[$user]($style)";
        };
        directory = {
          format = "\n[$path](bold cyan)[/](bold green) ";
          style = "bold #b4befe";
        };

        character = {
          success_symbol = "[ -> ](bold green)";
          error_symbol = "[ -> ✗](bold red)";
          # error_symbol = "[ ](bold #89dceb)[ ✗](bold red)";
        };

        cmd_duration = {
          format = "[ 󰔛 $duration]($style)";
          disabled = false;
          style = "bg:none fg:#f9e2af";
          show_notifications = false;
          min_time_to_notify = 60000;
        };

        git_branch = {
          format = "\non [$symbol$branch](bold purple)";
          symbol = " ";
          truncation_length = 15;
          style = "bold purple";
        };

        custom.shellver = {
          command = "zsh --version";
          when = ''test $SHELL = "/run/current-system/sw/bin/zsh"'';
          symbol = "";
          style = "bold magenta";
        };
      };
    };
  };
}
