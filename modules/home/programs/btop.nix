{lib, config, pkgs, ...}: {
  options = {
    btopConfig.enable = lib.mkEnableOption "enables my btop config";
  };
  config = lib.mkIf config.btopConfig.enable {
    programs.btop = {
      enable = true;

      settings = {
        update_ms = 500;
        vim_keys = true;
        color_theme = "nord";
        theme_background = true;
        temp_scale = "fahrenheit";
        graph_symbol = "block";
        disks_filter = "exclude=/boot /";
        show_swap = false;
        swap_disk = false;
      };
    };

    home.packages = with pkgs; [nvtopPackages.intel];
  };
}
