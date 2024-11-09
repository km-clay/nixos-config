{ config, lib, inputs, ... }: {
  options = {
    movOpts.envConfig.starshipConfig.enable =
      lib.mkEnableOption "enables my starship configuration";
  };
  config = lib.mkIf config.movOpts.envConfig.starshipConfig.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = false;
      settings = {
        add_newline = true;
        right_format = "($custom)";

        format = lib.concatStrings [
          "($ssh_symbol)($username)($hostname)(bold white)($cmd_duration)($character)"
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
          format = ''

            [$path](bold cyan)[/](bold green) '';
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
          format = ''

            on [$symbol$branch](bold purple)'';
          symbol = " ";
          truncation_length = 15;
          style = "bold purple";
        };

        hostname = {
          ssh_symbol = "🌐";
          ssh_only = false;
          format = "[@](bold blue)[$hostname](bold red)";
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
