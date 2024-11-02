{lib, config, ...}: {
  options = {
    steamConfig.enable = lib.mkEnableOption "enables steam configuration";
  };
  config = lib.mkIf config.steamConfig.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
