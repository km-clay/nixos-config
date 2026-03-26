args:
let
  inherit (args) username;
in
{
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "/home/${username}/.password-store";
    };
  };
}
