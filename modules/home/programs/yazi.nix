args:
let
  inherit (args) lib;
in
{
  programs.yazi = {
    enable = true;
    theme = lib.mkForce {};
    enableZshIntegration = true;
    shellWrapperName = "y";
  };
}
