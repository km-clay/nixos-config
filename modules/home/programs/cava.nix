{lib, config, inputs, pkgs, ... }: {
  options = {
    cavaConfig.enable = lib.mkEnableOption "enables my cava settings";
  };
  config = lib.mkIf config.cavaConfig.enable {
    programs.cava = {
      enable = true;
    };
  };
}
