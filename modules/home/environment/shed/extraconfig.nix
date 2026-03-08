{ lib, config, self, pkgs, ... }:
let
  shellsound = "${pkgs.myScripts.playshellsound}/bin/playshellsound";
  color-commit = "${pkgs.myScripts.color-commit}/bin/color-commit";
  sndpath = "${self}/assets/sound";
in
{
  programs.shed = {
    settings.extraPostConfig = /* bash */ ''
      export PS1="\@prompt "
      export PSR='\e[36;1m$\@shed_ver\e[0m'

      export PROMPT_GIT_LINE="$(prompt_git_line)"

      if [ "$0" = "-shed" ]; then
        ${shellsound} $FLAKEPATH/assets/sound/login.wav
      fi
    '';
  };
}
