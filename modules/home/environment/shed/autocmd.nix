{ self, pkgs, ... }:
let
  shellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  color-commit = "${pkgs.myScripts.color-commit}/bin/color-commit";
  sndpath = "${self}/assets/sound";
in
{
  programs.shed = {
    autocmds = [
      {
        hooks = [ "post-cmd" ];
        command = "export PROMPT_GIT_LINE=\"$(prompt_git_line)\"";
      }
      {
        hooks = [ "on-history-open" ];
        command = ''[ -n "$_NUM_MATCHES" ] && [ "$_NUM_MATCHES" -gt 0 ] && ${shellsound} "${sndpath}/nvim.wav"; fi'';
      }
      {
        hooks = [ "on-completion-start" ];
        command = ''[ -n "$_NUM_MATCHES" ] && [ "$_NUM_MATCHES" -gt 1 ] && ${shellsound} "${sndpath}/nvim.wav"; fi'';
      }
    ];
  };
}
