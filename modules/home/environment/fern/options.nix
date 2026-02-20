{ lib, config, ... }:

{
  programs.fern = {
    enable = true;

    settings = {
      autocd = true;
      autoHistory = true;
    };
  };
}
