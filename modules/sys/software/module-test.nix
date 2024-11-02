{ pkgs, lib, config, ... }:
{
  options = {
    testmodule.enable = lib.mkEnableOption "enables test module";
  };
  config = lib.mkIf config.testmodule.enable {
    environment.systemPackages = with pkgs; [
      hello
    ];
  };
}
