{ lib, config, ... }:
{
  programs.shed = {
    extraCompletion = {
      cargo = {
        wordList = [
          "build"
          "test"
          "run"
          "clippy"
        ];
      };
    };
  };
}
