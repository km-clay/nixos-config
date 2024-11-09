{ lib, config, inputs, ... }: {
  options = {
    movOpts.programConfigs.batConfig.enable =
      lib.mkEnableOption "enables my bat options";
  };
  config = lib.mkIf config.movOpts.programConfigs.batConfig.enable {
    programs.bat = {
      enable = true;
      config = { pager = "less -FR"; };
    };
  };
}
