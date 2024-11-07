{lib, config, ...}: {
  options = {
    movOpts.steamConfig.enable = lib.mkEnableOption "enables steam configuration";
  };
  config = lib.mkIf config.movOpts.steamConfig.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
