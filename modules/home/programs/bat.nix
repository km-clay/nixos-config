{lib, config, inputs, ...}: {
  options = {
    movOpts.batConfig.enable = lib.mkEnableOption "enables my bat options";
  };
  config = lib.mkIf config.movOpts.batConfig.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
  };
}
