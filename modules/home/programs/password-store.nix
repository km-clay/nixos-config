{ lib, config, username, ... }:
let home = "/home/${username}";
in {
  options = {
    movOpts.programConfigs.passConfig.enable =
      lib.mkEnableOption "enables my pass config";
  };
  config = lib.mkIf config.movOpts.programConfigs.passConfig.enable {
    programs.password-store = {
      enable = true;
      settings = { PASSWORD_STORE_DIR = "${home}/.password-store"; };
    };
  };
}
