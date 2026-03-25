{
  lib,
  config,
  self,
  pkgs,
  ...
}:
let
  shellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  color-commit = "${pkgs.myScripts.color-commit}/bin/color-commit";
  sndpath = "${self}/assets/sound";
in
{
  programs.shed = {
    extraPostConfig = /* bash */ ''
      export PS1="\@prompt "
      export PSR='\e[36;1m$\@shed_ver\e[0m'

      if [ "$PROMPT_GIT" -eq 1 ]; then
        export PROMPT_GIT_LINE="$(prompt_git_line)"
      else
        export PROMPT_GIT_LINE=""
      fi

      if [ "$0" = "-shed" ]; then
        ${shellsound} $FLAKEPATH/assets/sound/login.wav
      fi

      if [ -n "$LS_COLORS" ]; then unset LS_COLORS; fi
    '';
  };
}
