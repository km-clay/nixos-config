{lib, config, ...}: {
  options = {
    movOpts.softwareCfg.steamConfig.enable = lib.mkEnableOption "enables steam configuration";
  };
  config = lib.mkIf config.movOpts.softwareCfg.steamConfig.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
