host: args:
let
  inherit (args) username lib;
in
{
  imports = lib.optionals (host != null) [ (import ./${host}/home.nix args) ];

  home.username = lib.mkDefault "${username}";
  home.homeDirectory = lib.mkDefault "/home/${username}";
  home.stateVersion = lib.mkDefault "24.05";

  programs.home-manager.enable = lib.mkDefault true;

  movOpts = {
    envConfig = {
      spicetifyConfig.enable = lib.mkDefault false;
    };
  };
}
