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
    settings = {
      opener = {
        audio = [
          {
            run = "aplay \"$@\"";
            block = false;
            desc = "Play audio";
          }
        ];
      };
      open = {
        rules = [
          {
            url = "*.wav";
            use = "audio";
          }
          {
            url = "*.ogg";
            use = "audio";
          }
          {
            mime = "audio/*";
            use = "audio";
          }
        ];
      };
    };
  };
}
