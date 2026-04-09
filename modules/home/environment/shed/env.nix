{ lib, config, ... }:
{
  programs.shed = {
    environmentVars = {
      SOUNDS_ENABLED = "true";
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      BROWSER = "firefox";
      FLAKEPATH = "$HOME/.sysflake";
      STEAMPATH = "$HOME/.local/share/Steam";

      FZF_DEFAULT_COMMAND = "fd";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";

      LESS = "-R"; # pager uses alt buffer
      PAGER = "less";
      SHED_HPAGER = "h_pager";
      PROMPT_GIT = "1";
    };
  };
}
