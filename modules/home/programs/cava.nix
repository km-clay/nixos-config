{ lib, config, inputs, pkgs, ... }: {
  options = {
    movOpts.programConfigs.cavaConfig.enable =
      lib.mkEnableOption "enables my cava settings";
  };
  config = lib.mkIf config.movOpts.programConfigs.cavaConfig.enable {
    programs.cava = { enable = true; };
  };
}
