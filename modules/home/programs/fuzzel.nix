{config, lib, ...}: {
  options = {
    movOpts.fuzzelConfig.enable = lib.mkEnableOption "enables my fuzzel configuration";
  };
  config = lib.mkIf config.movOpts.fuzzelConfig.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          line-height = 25;
          fields = "name,generic,comment,categories,filename,keywords";
          terminal = "kitty";
          prompt = "' ➜  '";
          layer = "top";
          lines = 10;
          width = 35;
          horizontal-pad = 25;
          inner-pad = 5;
        };
        border = {
          radius = 15;
          width = 3;
        };
        colors.background = lib.mkForce "2e344080";
      };
    };
  };
}
