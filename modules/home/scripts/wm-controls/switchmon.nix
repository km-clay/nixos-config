{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "switchmon";
  text = ''
    #!/bin/zsh

    hyprctl dispatch focusmonitor "$(hyprctl -j monitors | jq -r '.[] | select(.focused == false) | .name')"
  '';
}
