{ lib, config, ... }:

{
  options = {
    movOpts.envConfig.zshConfig.envVariables.enable = lib.mkEnableOption "enables my default session variables";
  };
  config = lib.mkIf config.movOpts.envConfig.zshConfig.envVariables.enable {
    programs.zsh = {
      sessionVariables = {
        SOUNDS_ENABLED = "true";
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";
        VISUAL = "nvim";
        LANG = "en_US.UTF-8";
        BROWSER = "firefox";
        FLAKEPATH = "$HOME/.sysflake";
        STEAMPATH = "$HOME/.local/share/Steam";
        TFPATH = "$STEAMPATH/steamapps/common/Team Fortress 2/";
        PATH = "$PATH:$HOME/.userpath/";
        FZF_DEFAULT_COMMAND = "fd";
        FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
      };
    };
  };
}
