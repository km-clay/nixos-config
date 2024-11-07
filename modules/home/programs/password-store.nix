{lib, config, username, ...}: let
  home = "/home/${username}";
in {
  options = {
    movOpts.passConfig.enable = lib.mkEnableOption "enables my pass config";
  };
  config = lib.mkIf config.movOpts.passConfig.enable {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "${home}/.password-store";
      };
    };
  };
}
