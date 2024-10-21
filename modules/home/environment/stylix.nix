{
  pkgs,
	scheme,
	wallpaper,
  ...
}:

{
  stylix = {
    enable = true;
    autoEnable = true;
   targets = {
   #  fzf.enable = true;
   #  kitty.enable = true;
   #  vesktop.enable = true;
     waybar.enable = false;
   };
  };
}
