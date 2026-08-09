host: args:
let
  inherit (args) username lib;
in
{
  imports = lib.optionals (host != null) [ (import ./${host}/home.nix args) ];

  home.username = lib.mkDefault "${username}";
  home.homeDirectory = lib.mkDefault "/home/${username}";
  home.stateVersion = lib.mkDefault "24.05";
  home.pointerCursor.enable = true;

  programs.home-manager.enable = lib.mkDefault true;

  movOpts = {
    envConfig = {
      spicetifyConfig.enable = lib.mkDefault false;
      zshConfig = {
        shellAliases.enable = lib.mkForce false;
        shellOptions.enable = lib.mkForce false;
        envVariables.enable = lib.mkForce false;
        extraConfig.enable = lib.mkForce false;
      };
    };
  };
}
