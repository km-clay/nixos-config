{ lib, config, ... }:

{
  programs.shed = {
    enable = true;

    settings = {
      autocd = true;
      autoHistory = true;
      maxHistoryEntries = -1;
    };
  };
}
