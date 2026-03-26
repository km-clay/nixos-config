args:
let
  inherit (args) username config;
in
{
  programs.git = {
    enable = true;
    signing.format = "openpgp";
    settings = {
      user = {
        email = "kylerclay@proton.me";
        name = "${username}";
      };
      alias = {
        draft = "!if git rev-parse > /dev/null 2>&1; then echo \"$1\" >> $(git rev-parse --git-dir)/DRAFT_MSG; else exit 1; fi #";
      };
      safe = {
        directory = [
          "${config.home.homeDirectory}/mnt/net"
        ];
      };
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = "true";
      delta.dark = "true";
      merge.conflictstyle = "zdiff3";
    };
  };
}
