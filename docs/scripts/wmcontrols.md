# Custom Hyprland Controls

None of these are meant to be invoked directly in the terminal and are mainly used as helpers for my other scripts. I will
still document them in case you wish to use them in your own scripts.

## chscheme
  - Opens a fzf menu containing all of the color schemes contained in the base16schemes package in nixpkgs. The fzf preview contains the colors so you can see them in your terminal before you choose them.
  - Usage:
    - `chscheme` - Does not take arguments.
  - Defined in 'modules/home/scripts/wm-controls/chscheme.nix'

## chpaper
  - Opens a fzf menu containing all of the wallpapers held in $FLAKEPATH/assets/wallpapers. The fzf preview shows the image file that the user is hovering over.
  - Usage:
    - `chpaper` - Does not take arguments.
  - Defined in 'modules/home/scripts/wm-controls/chpaper.nix'

## keyring
  - Opens a fzf menu containing all of the directories/files contained in ~/.password-store. Selecting one uses `pass -c` to copy it to the clipboard. The script pauses the clipboard history daemon while it does this so that the password is not added to your clipboard history. If anyone can think of a more secure way to do this, let me know. Password is cleared from the clipboard automatically after 10 seconds if not overwritten by something else.
  - Usage:
    - `keyring` - Does not take arguments.
  - Defined in 'modules/home/scripts/wm-controls/keyring.nix'

## mkscreenshots
  - If workspace 4 is empty, switches to that workspace and takes some screenshots that showcase the desktop environment. These screenshots are then saved to $FLAKEPATH/assets/screens, overwriting the old ones. README.md is then updated to include the commit that the screenshots were taken on.
  - Usage:
    - `mkscreenshots` - Does not take arguments. Only runs if workspace 4 has no windows.
  - Defined in 'modules/home/scripts/wm-controls/mkscreenshots.nix'

## moveonscreen
  - Uses hyprctl to move the currently active window, if it is floating. The window moves relative to the cursor, and will not move past the bounds of the screen. Used by toolbelt to produce the cool window movements.
  - Usage:
    - `moveonscreen` - Moves the window to the cursor's position, anchored at the top-left corner. Does not leave the bounds of the screen.
    - `moveonscreen --center` - Behaves the same way, except anchors at the center of the window instead of the top-left corner.
  - Defined in 'modules/home/scripts/wm-controls/moveonscreen.nix'

## s_check
  - A simple test invocation checking to see if $SOUNDS_ENABLED is 0 or 1. Don't ask why this doesn't work as a zsh alias, because it doesn't for some reason and I don't really know why. Does not return anything except for the status code from the test.
  - Usage:
    - `s_check` - Does not take arguments.
  - Defined in 'modules/home/scripts/wm-controls/switchmon.nix'

## switchmon
  - Uses hyprctl to switch the focused monitor to the other monitor. Currently only supports setups with two monitors.
  - Usage:
    - `switchmon` - Does not take arguments.
  - Defined in 'modules/home/scripts/wm-controls/switchmon.nix'
