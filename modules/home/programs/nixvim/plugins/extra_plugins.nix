{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        # vimwiki
        name = "vimwiki";
        src = pkgs.fetchFromGitHub {
          owner = "vimwiki";
          repo = "vimwiki";
          rev = "705ad1e0dded0e3b7ff5fac78547ab67c9d39bdf";
          hash = "sha256-Upx29rIPwW/e7Lkmf0PNOpIACnAXIzlkfa6V1p2nYHM=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-sneak";
        src = pkgs.fetchFromGitHub {
          owner = "justinmk";
          repo = "vim-sneak";
          rev = "c13d0497139b8796ff9c44ddb9bc0dc9770ad2dd";
          hash = "sha256-ndWhnV0fgCcqCGwVyM07GfmUB3CitBZbOWvZtsB1tBk=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "vim-slash";
        src = pkgs.fetchFromGitHub {
          owner = "junegunn";
          repo = "vim-slash";
          rev = "31aee09b7ea8893a18fa34f65e63e364fc998444";
          hash = "sha256-hC590lmKBssLCSKPF9O2cnt6TCJkklzbbhDNhf1ozUU=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "automkdir.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "mateuszwieloch";
          repo = "automkdir.nvim";
          rev = "beeb2dd76f1c3ac776d901c43217a774f1f045de";
          hash = "sha256-lKSCZ80b/+OV56858FDK7x/zhcuU/AWuCDe+8NdhziU=";
        };
      })
      #(pkgs.vimUtils.buildVimPlugin {
      #name = "nvim-ghost.nvim";
      #src = pkgs.fetchFromGitHub {
      #owner = "subnut";
      #repo = "nvim-ghost.nvim";
      #rev = "67cc8f38c69d271af1c2430ff5099766f3550eb8";
      #hash = "sha256-XldDgPqVeIfUjaRLVUMp88eHBHLzoVgOmT3gupPs+ao=";
      #};
      #})
    ];
  };
}
