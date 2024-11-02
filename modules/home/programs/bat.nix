{lib, config, inputs, ...}: {
  options = {
    batOpts.enable = lib.mkEnableOption "enables my bat options";
  };
  config = lib.mkIf config.batOpts.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
  };
}
