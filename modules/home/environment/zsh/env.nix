{ lib, config, ... }:

{
  options = {
    movOpts.envConfig.zshConfig.envVariables.enable = lib.mkEnableOption "enables my default session variables";
  };
  config = lib.mkIf config.movOpts.envConfig.zshConfig.envVariables.enable {
    programs.zsh = {
      sessionVariables = {
        SOUNDS_ENABLED = "1";
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";
        VISUAL = "nvim";
        LANG = "en_US.UTF-8";
        BROWSER = "firefox";
        FLAKEPATH = "$HOME/.sysflake";
        STEAMPATH = "$HOME/.local/share/Steam";
        PATH = "$PATH:$HOME/.userpath/";
      };
    };
  };
}
