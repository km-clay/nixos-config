{ pkgs, ... }:
{
  programs.shed = {
    autocmds = [
      {
        hooks = [ "post-cmd" ];
        command = ''if [ "''${STATLINE_GIT:-0}" -eq 1 ]; then git_stat_line_update; else export GIT_STAT_LINE=""; fi'';
      }
      {
        hooks = [ "on-idle-timeout" ];
        command = ''if [ "''${STATLINE_GIT:-0}" -eq 1 ]; then LAST_DIFF=""; git_stat_line_update; else export GIT_STAT_LINE=""; fi'';
      }
      {
        hooks = [ "on-history-open" "on-completion-start"  ];
        command = ''if [ -n "$NUM_MATCHES" ] && [ "$NUM_MATCHES" -gt 0 ]; then playshellsound "ls.wav"; fi'';
      }
      {
        hooks = [ "on-idle-timeout" ];
        command = "if (( (IDLE_SECONDS % 600) == 0 )); then ${pkgs.whoa}/bin/whoa; fi";
      }
      {
        hooks = [ "pre-change-dir" ];
        command = "playshellsound 'cd.wav'";
      }
      {
        hooks = [ "pre-change-dir" ];
        command = "__ls_no_sound \"$NEW_DIR\"";
      }
    ];
  };
}
