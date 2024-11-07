{...}: {
  programs.nixvim = {
    autoCmd = [
      {
        command = "FloatermNew --wintype=float --name=shadeterm --position=topright --autoclose=0 --silent --cwd=<buffer> --titleposition=left zsh";
        event = ["VimEnter"];
        pattern = ["*"];
        desc = "Create a floating terminal, placed in the top right";
      }
      {
        command = "silent! mkview";
        event = ["BufWinLeave"];
        pattern = ["*"];
        desc = "Save session window settings to be loaded next time the file is opened";
      }
      {
        command = "silent! !aplay ~/sound/sys/cd.wav > /dev/null 2>&1 &";
        event = ["BufWinLeave"];
        pattern = ["*"];
        desc = "Play a neat little sound effect when you close neovim";
      }
      {
        command = "silent! loadview";
        event = ["BufWinEnter"];
        pattern = ["*"];
        desc = "Load previous session window settings for the opened file (folds, cursor pos, etc)";
      }
      {
        command = "setlocal textwidth=135";
        event = ["BufWinEnter" "BufEnter"];
        pattern = ["*.md" "*.wiki" "*.txt"];
        desc = "Set automatic linebreaks in plain text file formats";
      }
    ];
  };
}
