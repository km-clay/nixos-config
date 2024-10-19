{
  pkgs,
  self,
	lib,
  ...
}: 

let
  wallpaper = "${self}/media/wallpapers/sine.png";

	# Generate base16 color scheme from wallpaper
	scheme_string_step1 = pkgs.runCommand "scheme_string" { }''
		${pkgs.flavours}/bin/flavours generate dark ${wallpaper} --stdout | sed 's/"//g' | sed 's/://' | tail -n 16 > $out
	'';
	scheme_string = builtins.readFile scheme_string_step1;
	scheme_list = lib.filter (x: x != "") (lib.splitString "\n" scheme_string);
	scheme_set = lib.lists.foldl' (acc: line:
		let
			splitLine = lib.splitString " " line;
			key = builtins.elemAt splitLine 0;
			value = builtins.elemAt splitLine 1;
		in
		acc // { "${key}" = value; }
	) {} scheme_list;
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
    image = wallpaper;
    polarity = "dark";
    autoEnable = true;
		opacity.terminal = 0.95;
    targets = {
      console.enable = true;
      feh.enable = true;
      grub.enable = true;
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["Iosevka"];};
        name = "Iosevka Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerdfonts.override {fonts = ["Iosevka"];};
        name = "Iosevka Nerd Font";
      };
      serif = {
        package = pkgs.nerdfonts.override {fonts = ["Iosevka"];};
        name = "Iosevka Nerd Font";
      };
			sizes = {
				desktop = 10;
				applications = 14;
				terminal = 16;
				popups = 12;
			};
    };
  };
}
