{ lib, config, ... }:

{
  options = {
    movOpts.envConfig.zshConfig.shellOptions.enable = lib.mkEnableOption "enables my default shell settings";
  };
  config = lib.mkIf config.movOpts.envConfig.zshConfig.shellOptions.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "fzf" ];
      };

      enableCompletion = true;

      history = {
        path = "$HOME/.zsh_history";
        save = 10000;
        size = 10000;
        share = true;
      };

      autosuggestion = {
        enable = true;
        highlight = "fg=#4C566A,underline";
      };
    };
  };
}
