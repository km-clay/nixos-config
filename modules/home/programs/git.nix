{ lib, config, username, pkgs, ... }: {
  options = {
    movOpts.programConfigs.gitConfig.enable =
      lib.mkEnableOption "enables my git configuration";
  };
  config = lib.mkIf config.movOpts.programConfigs.gitConfig.enable {
    programs.git = {
      enable = true;
      signing = {
        gpgPath = "${pkgs.gnupg}/bin/gpg";
        key = "76118C11E525D3D0CBCA0F6EB2A3D477E86843DB";
        signByDefault = true;
      };
      userEmail = "kylerclay@proton.me";
      userName = "${username}";
    };
  };
}
