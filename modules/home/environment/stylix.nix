{lib, config, pkgs, ... }: {
  options = {
    movOpts.stylixHomeConfig.enable = lib.mkEnableOption "enables my stylix Home-Manager options";
  };
  config = lib.mkIf config.movOpts.stylixHomeConfig.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      targets = {
        #  fzf.enable = true;
        #  kitty.enable = true;
        #  vesktop.enable = true;
        waybar.enable = false;
        btop.enable = false;
      };
    };
  };
}
