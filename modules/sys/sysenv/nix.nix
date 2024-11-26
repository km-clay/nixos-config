{ lib, config, ... }: {
  options = {
    movOpts.sysEnv.nixSettings.enable =
      lib.mkEnableOption "enables my nixos settings";
  };
  config = lib.mkIf config.movOpts.sysEnv.nixSettings.enable {
    system.stateVersion = "25.05";
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [ "https://nix-gaming.cachix.org" ];
      };
    };
    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
