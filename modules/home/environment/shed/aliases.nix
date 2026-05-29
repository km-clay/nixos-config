{ ... }:
{
  programs.shed = {
    aliases = {
      mv = "mv -v";
      cp = "cp -vr";
      gt = "gtrash";
      gtp = "playshellsound rm.wav && gtrash put";
      diff = "diff --color=auto";
      sr = "source $XDG_CONFIG_HOME/shed/shedrc";
      psg = "ps aux | grep -v grep | grep -i -e VSZ -e";
      mkdir = "mkdir -p";
      pk = "pkill -9 -f";
      svc = "sudo systemctl";
      svcu = "systemctl --user";
      iv = "invoke";
      cfgfilecount = ''find ".\.nix" $FLAKEPATH | wc -l | toilet -f 3d | lolcat'';
      vide = "neovide";
      vi = "nvim";
      mkexe = "chmod +x";
      shortdate = "date +%m-%d-%y";
      suvi = "sudoedit";
      suvide = "EDITOR=neovide suvi";
      rustdev = "nix develop github:km-clay/devshells#rust";
      y = "yazi";

      ga = "playshellsound gitadd.wav; git add";
      gcomm = "gitcommit_sfx";
      gpush = "gitpush_sfx";
      gpull = "gitpull_sfx";
      grebase = "gitrebase_sfx";
      lgit = "lazygit";
      videconf = "EDITOR=neovide viconf";
      nix-shell = "command nix-shell --command 'exec shed'";
    };
  };
}
