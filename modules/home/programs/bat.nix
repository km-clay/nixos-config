{lib, config, inputs, ...}: {
  options = {
    batConfig.enable = lib.mkEnableOption "enables my bat options";
  };
  config = lib.mkIf config.batConfig.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
  };
}
