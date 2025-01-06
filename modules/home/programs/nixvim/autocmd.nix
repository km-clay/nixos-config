{ pkgs, self, ... }: {
  programs.nixvim = {
    autoCmd = [
      {
        command = "silent! mkview";
        event = [ "BufWinLeave" ];
        pattern = [ "*" ];
        desc =
          "Save session window settings to be loaded next time the file is opened";
      }
      {
        command = "silent! loadview";
        event = [ "BufWinEnter" ];
        pattern = [ "*" ];
        desc =
          "Load previous session window settings for the opened file (folds, cursor pos, etc)";
      }
      {
        command = "silent! FloatermNew --name=def_term --width=0.8 --height=0.8 --wintype=topright --silent";
        event = [ "VimEnter" ];
        pattern = [ "*" ];
        desc = "Start the floaterm window";
      }
    ];
  };
}
