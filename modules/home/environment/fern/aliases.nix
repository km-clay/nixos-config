{ lib, config, self, ... }:
{
  programs.fern = {
    aliases = {
      mv = "mv -v";
      cp = "cp -vr";
      gt = "gtrash";
      gtp = "playshellsound ${self}/assets/sound/rm.wav";
      sr = "source ~/.fernrc";
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
      suvide = "EDITOR=neovide; suvi";
      rustdev = "nix develop github:km-clay/devshells#rust";

      ga = "playshellsound ${self}/assets/sound/gitadd.wav; git add";
      gcomm = "gitcommit_sfx";
      gpush = "gitpush_sfx";
      gpull = "gitpull_sfx";
      grebase = "gitrebase_sfx";
    };
  };
}
