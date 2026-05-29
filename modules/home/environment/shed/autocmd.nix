{ ... }:
{
  programs.shed = {
    autocmds = [
      {
        hooks = [ "post-cmd" ];
        # git_stat_line_update exports GIT_STAT_LINE as a side effect; calling
        # it directly refreshes the cached display string. Clear it explicitly
        # when the feature is disabled so stale content doesn't linger.
        command = ''if [ "''${STATLINE_GIT:-0}" -eq 1 ]; then git_stat_line_update; else export GIT_STAT_LINE=""; fi'';
      }
      {
        hooks = [ "on-history-open" ];
        command = ''[ -n "$_NUM_MATCHES" ] && [ "$_NUM_MATCHES" -gt 0 ] && shellsound "nvim.wav"; fi'';
      }
      {
        hooks = [ "on-completion-start" ];
        command = ''[ -n "$_NUM_MATCHES" ] && [ "$_NUM_MATCHES" -gt 1 ] && shellsound "nvim.wav"; fi'';
      }
    ];
  };
}
