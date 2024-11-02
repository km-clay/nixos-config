{lib, config, pkgs, ...}: {
  options = {
    sysProgs.enable = lib.mkEnableOption "enables default system programs";
  };
  config = lib.mkIf config.sysProgs.enable {
    programs = {
      hyprland.enable = true;
      zsh.enable = true;
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          ffmpeg-full
        ];
      };
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
