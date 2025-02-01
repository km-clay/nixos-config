{ lib, config, self, ... }:
{
  options.movOpts.envConfig.zshConfig.shellAliases.enable = lib.mkEnableOption "enables my zsh aliases";
  config = lib.mkIf config.movOpts.envConfig.zshConfig.shellAliases.enable {
    programs.zsh = {
      shellAliases = {
        grep = "rg";
        find = "fd";
        cat = "bat";
        yazi = "y";
        mv = "mv -v";
        cp = "cp -vr";
        gt = "gtrash";
        gtp = "playshellsound ${self}/assets/sound/rm.wav; gtrash put";
        sr = "source ~/.zshrc && source ~/.zshenv";
        ".." = "cd ..";
        rm = "echo 'use \"gtp\" instead'";
        psg = "ps aux | grep -v grep | grep -i -e VSZ -e";
        mkdir = "mkdir -p";
        pk = "pkill -9 -f";
        svcu = "systemctl --user";
        svc = "sudo systemctl";
        viflake = "nvim flake.nix";
        iv = "invoke";
        cfgfilecount = ''find ".\.nix" $FLAKEPATH | wc -l | toilet -f 3d | lolcat'';
        record = "wf-recorder";
        #git
        ga = "playshellsound ${self}/assets/sound/gitadd.wav; git add";
        gcomm = "gitcommit_sfx";
        gpush = "gitpush_sfx";
        gpull = "gitpull_sfx";
        greb = "gitrebase_sfx";
        rsh = "$HOME/Coding/projects/rust/rsh/target/debug/rsh";
        vide = "neovide";
        pk9 = "pkill -9";
      };
    };
  };
}
