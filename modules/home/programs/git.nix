{ lib, config, username, pkgs, ... }: {
  options = {
    movOpts.programConfigs.gitConfig.enable =
      lib.mkEnableOption "enables my git configuration";
  };
  config = lib.mkIf config.movOpts.programConfigs.gitConfig.enable {
    programs.git = {
      enable = true;
      signing = {
        signer = "${pkgs.gnupg}/bin/gpg";
        key = "2453DF4EF63B92D5D8FE8C9DC741C9DFD8156540";
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
