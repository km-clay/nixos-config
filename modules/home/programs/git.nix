{ lib, config, username, pkgs, ... }: {
  options = {
    movOpts.programConfigs.gitConfig.enable =
      lib.mkEnableOption "enables my git configuration";
  };
  config = lib.mkIf config.movOpts.programConfigs.gitConfig.enable {
    programs.git = {
      enable = true;
      signing = {
        gpgPath = "${pkgs.gnupg}/bin/gpg";
        key = "0DA69D51BA4B2D2B58FC9CB574ED6528A37CA99A";
        signByDefault = true;
      };
      userEmail = "kylerclay@proton.me";
      userName = "${username}";
      extraConfig = {
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta.navigate = "true";
        delta.dark = "true";
        merge.conflictstyle = "zdiff3";
      };
    };
  };
}
