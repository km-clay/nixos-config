{
scheme,
...
}:

let
	bg = {
		darkester = scheme.base00;
		darkest = scheme.base01;
		darker = scheme.base02;
		dark = scheme.base03;
	};
	fg = {
		lightester = scheme.base07;
		lightest = scheme.base06;
		lighter = scheme.base05;
		light = scheme.base04;
	};
	colors = {
		color0 = scheme.base08;
		color1 = scheme.base09;
		color2 = scheme.base0A;
		color3 = scheme.base0B;
		color4 = scheme.base0C;
		color5 = scheme.base0D;
		color6 = scheme.base0E;
		color7 = scheme.base0F;
	};
in
{
  programs.waybar.style = ''
  '';
}
