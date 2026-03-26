args:
let
  inherit (args) lib;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      add_newline = true;
      right_format = "($custom)";

      format = lib.concatStrings [
        "($ssh_symbol)($username)($hostname)($nix_shell)(bold white)($cmd_duration)($character)"
        "($git_branch)($git_status)($rust)"
        "($directory)"
        "$line_break[  ](bold #89b4fa)"
      ];

      username = {
        show_always = true;
        style_user = "bold white";
        format = "[$user]($style)";
      };

      rust = {
        format = " via [$symbol($version)]($style)";
      };

      directory = {
        format = ''

          [$path](bold cyan)[/](bold green) '';
        style = "bold #b4befe";
      };

      character = {
        success_symbol = "[ -> ](bold green)";
        error_symbol = "[ -> ✗](bold red)";
      };

      cmd_duration = {
        format = "[󰔛 $duration]($style)";
        disabled = false;
        style = "bg:none fg:#f9e2af";
        show_notifications = false;
        min_time_to_notify = 60000;
      };

      git_branch = {
        format = ''

          on [$symbol$branch](bold purple)'';
        symbol = " ";
        truncation_length = 15;
        style = "bold purple";
      };

      hostname = {
        ssh_symbol = "🌐";
        ssh_only = false;
        format = "[@](bold blue)[$hostname $ssh_symbol](bold red)";
      };

      nix_shell = {
        format = " via [$symbol]($style)";
        symbol = " ";
      };

      custom.shellver = {
        command = "zsh --version";
        when = ''test $SHELL = "/run/current-system/sw/bin/zsh"'';
        symbol = "";
        style = "bold magenta";
      };
    };
  };
}
