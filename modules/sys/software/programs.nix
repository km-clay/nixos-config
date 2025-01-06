{ lib, config, pkgs, ... }: {
  options = {
    movOpts.softwareCfg.sysProgs.enable =
      lib.mkEnableOption "enables default system programs";
  };
  config = lib.mkIf config.movOpts.softwareCfg.sysProgs.enable {
    environment.etc."shells" = {
      enable = true;
      text = ''
/run/current-system/sw/bin/zsh
/run/current-system/sw/bin/bash
/run/current-system/sw/bin/zsh
/nix/store/m7l6yzmflrf9hjs8707lk9nkhi6f73n1-zsh-5.9/bin/zsh
/run/current-system/sw/bin/bash
/run/current-system/sw/bin/sh
/nix/store/f33kh08pa7pmy4kvsmsibda46sh46s66-bash-interactive-5.2p37/bin/bash
/nix/store/f33kh08pa7pmy4kvsmsibda46sh46s66-bash-interactive-5.2p37/bin/sh
/bin/sh
/home/pagedmov/Coding/projects/rust/rsh/target/debug/rsh
      '';
    };
    programs = {
      hyprland.enable = lib.mkDefault true;
      zsh.enable = lib.mkDefault true;
      nix-ld = {
        enable = lib.mkDefault true;
        libraries = with pkgs; [ stdenv.cc.cc ffmpeg-full ];
      };
      gnupg.agent = {
        enable = lib.mkDefault true;
        enableSSHSupport = lib.mkDefault true;
      };
    };
  };
}
