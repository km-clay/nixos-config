{lib, config, ...}: {
  options = {
    steamOpts.enable = lib.mkEnableOption "enables steam configuration";
  };
  config = lib.mkIf config.steamOpts.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
