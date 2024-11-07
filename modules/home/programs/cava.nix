{lib, config, inputs, pkgs, ... }: {
  options = {
    movOpts.cavaConfig.enable = lib.mkEnableOption "enables my cava settings";
  };
  config = lib.mkIf config.movOpts.cavaConfig.enable {
    programs.cava = {
      enable = true;
    };
  };
}
