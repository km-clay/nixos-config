{ pkgs, ... }: {
  programs.nixvim = {
    #extraPlugins = [
      #(pkgs.vimUtils.buildVimPlugin {
        #name = "haskell-tools.nvim";
        #src = pkgs.fetchFromGitHub {
          #owner = "mrcjkb";
          #repo = "haskell-tools.nvim";
          #rev = "39c4ced6f1bff1abc8d4df5027efd11ac38c6e6c";
          #hash = "sha256-f+M35EwAlHwjJ2Xs2u9FLnyH0FJT22D0LLShDXCbEEs=";
        #};
      #})
    #];
    #plugins = { haskell-scope-highlighting.enable = true; };
  };
}
