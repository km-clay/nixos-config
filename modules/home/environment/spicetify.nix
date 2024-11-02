{lib, config, pkgs, inputs, scheme, ... }: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  options = {
    spicetifyConfig.enable = lib.mkEnableOption "enable my spicetify options";
  };
  config = lib.mkIf config.spicetifyConfig.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "spotify"
      ];

    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      #colorScheme = "custom";

      #customColorScheme = {
      #	text = scheme.base06;
      #	subtext = scheme.base04;
      #	sidebar-text = scheme.base04;
      #	main = scheme.base00;
      #	sidebar = scheme.base01;
      #	shadow = scheme.base01;
      #	selected-row = scheme.base08;
      #	button = scheme.base0D;
      #	button-active = scheme.base0C;
      #	button-disabled = scheme.base02;
      #	tab-active = scheme.base0E;
      #	notification = scheme.base0A;
      #	notification-error = scheme.base09;
      #	misc = scheme.base0F;
      #};
    };
  };
}
