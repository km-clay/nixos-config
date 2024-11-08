{
  pkgs,
  self,
  lib,
  config,
  ...
}: {
  options = {
    movOpts.sysEnv.sddmConfig.enable = lib.mkEnableOption "enables custom sddm configuration";
  };
  config = lib.mkIf config.movOpts.sysEnv.sddmConfig.enable {
    environment.systemPackages = [
      (
        pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          font = "JetBrains Mono Nerd Font";
          fontSize = "14";
          loginBackground = true;
          background = "${self}/assets/wallpapers/dark-waves.jpg";
        }
      )
    ];
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
      package = pkgs.kdePackages.sddm;
    };
  };
}
