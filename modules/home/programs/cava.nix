{lib, config, inputs, pkgs, ... }: {
  options = {
    cavaOpts.enable = lib.mkEnableOption "enables my cava settings";
  };
  config = lib.mkIf config.cavaOpts.enable {
    programs.cava = {
      enable = true;
    };
  };
}
