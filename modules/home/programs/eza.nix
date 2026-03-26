_:
{
  programs.eza = {
    enable = true;
    enableZshIntegration = false;
    extraOptions = [
      "-1"
      "-h"
      "--group-directories-first"
    ];
    icons = "auto";
    git = true;
  };
}
