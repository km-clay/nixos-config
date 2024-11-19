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
      diff-so-fancy = {
        enable = true;
        markEmptyLines = false;
        stripLeadingSymbols = false;
      };
      extraConfig = {
        color.diff = {
          #         meta = "black yellow bold";
          #         frag = "white blue bold";
          old = "#A9B1D6 #301A1F";
          new = "#A9B1D6 #12261E";
          #         plain = "normal";
          #         whitespace = "reverse red";
        };
      };
    };
  };
}
