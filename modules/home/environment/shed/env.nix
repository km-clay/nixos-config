{ ... }:
{
  programs.shed = {
    environmentVars = {
      SOUNDS_ENABLED = "true";
      LANG = "en_US.UTF-8";
      BROWSER = "firefox";
      FLAKEPATH = "$HOME/.sysflake";
      STEAMPATH = "$HOME/.local/share/Steam";

      FZF_DEFAULT_COMMAND = "fd";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";

      LESS = "-R"; # pager uses alt buffer
      PAGER = "less";

      PS1 = "\\@prompt";

      PATH = "$PATH:$HOME/.cargo/bin";

      STATLINE_GIT = "1";
      LINE_SEP_LEFT="";
      LINE_SEP_RIGHT="";
    };
  };
}
