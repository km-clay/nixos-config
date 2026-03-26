{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    movOpts.sysEnv.consoleSettings.enable = lib.mkEnableOption "enables my console settings";
  };
  config = lib.mkIf config.movOpts.sysEnv.consoleSettings.enable {
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      earlySetup = true;
      font = "ter-v32b";
      packages = with pkgs; [ terminus_font ];
    };
  };
}
