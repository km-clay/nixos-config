{
  programs.nixvim = {
    plugins.vim-matchup = {
      enable = true;
      enableSurround = true;
      textObj.enable = true;
      motion = {
        enable = true;
        cursorEnd = true;
      };
      matchParen = {
        hiSurroundAlways = true;
        offscreen = {
          method = "popup";
        };
      };
      treesitterIntegration = {
        enable = true;
        includeMatchWords = true;
      };
    };
  };
}
