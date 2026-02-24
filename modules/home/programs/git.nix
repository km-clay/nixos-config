{ lib, config, username, pkgs, ... }: {
  options = {
    movOpts.programConfigs.gitConfig.enable =
      lib.mkEnableOption "enables my git configuration";
  };
  config = lib.mkIf config.movOpts.programConfigs.gitConfig.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          email = "kylerclay@proton.me";
          name = "${username}";
        };
        alias = {
          draft = "!if git rev-parse > /dev/null 2>&1; then echo \"$1\" >> $(git rev-parse --git-dir)/DRAFT_MSG; else exit 1; fi #";
        };
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta.navigate = "true";
        delta.dark = "true";
        merge.conflictstyle = "zdiff3";
      };
    };
  };
}
