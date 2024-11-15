# Custom Hyprland Controls

*Note*: None of these are meant to be invoked directly in the terminal and are primarily used as helpers for other scripts. However, they are documented here in case you wish to use them in your own scripts.

---

- **chscheme**
  - **Description**:
    - Opens an `fzf` menu containing all of the color schemes available in the `base16schemes` package from Nixpkgs.
    - The `fzf` preview shows the colors so you can see them in your terminal before choosing one.
  - **Usage**:
    - `chscheme` - Does not take arguments.
  - *Defined in*: `modules/home/scripts/wm-controls/chscheme.nix`

---

- **chpaper**
  - **Description**:
    - Opens an `fzf` menu containing all wallpapers in `$FLAKEPATH/assets/wallpapers`.
    - The `fzf` preview shows the image file the user is hovering over.
  - **Usage**:
    - `chpaper` - Does not take arguments.
  - *Defined in*: `modules/home/scripts/wm-controls/chpaper.nix`

---

- **keyring**
  - **Description**:
    - Opens an `fzf` menu containing all directories/files in `~/.password-store`.
    - Selecting an entry uses `pass -c` to copy it to the clipboard.
    - Temporarily pauses the clipboard history daemon to ensure the password is not added to clipboard history.
    - Automatically clears the password from the clipboard after 10 seconds unless overwritten.
  - **Usage**:
    - `keyring` - Does not take arguments.
  - *Defined in*: `modules/home/scripts/wm-controls/keyring.nix`

---

- **mkscreenshots**
  - **Description**:
    - Switches to workspace 4 (if empty) and takes screenshots showcasing the desktop environment.
    - Saves the screenshots to `$FLAKEPATH/assets/screens`, overwriting the old ones.
    - Updates `README.md` to include the commit hash of the current screenshots.
  - **Usage**:
    - `mkscreenshots` - Does not take arguments. Only runs if workspace 4 has no windows.
  - *Defined in*: `modules/home/scripts/wm-controls/mkscreenshots.nix`

---

- **moveonscreen**
  - **Description**:
    - Uses `hyprctl` to move the currently active floating window relative to the cursor.
    - Prevents the window from moving outside the screen bounds.
    - Often used with `toolbelt` for smooth window movements.
  - **Usage**:
    - `moveonscreen` - Moves the window to the cursor's position, anchored at the top-left corner.
    - `moveonscreen --center` - Moves the window to the cursor's position, anchored at the center of the window.
  - *Defined in*: `modules/home/scripts/wm-controls/moveonscreen.nix`

---

- **s_check**
  - **Description**:
    - Tests whether `$SOUNDS_ENABLED` is set to `0` or `1`.
    - Does not return anything except the status code from the test.
    - *Note*: This does not work as a Zsh alias for unknown reasons.
  - **Usage**:
    - `s_check` - Does not take arguments.
  - *Defined in*: `modules/home/scripts/wm-controls/switchmon.nix`

---

- **switchmon**
  - **Description**:
    - Uses `hyprctl` to switch focus between two monitors.
    - Only supports setups with two monitors.
  - **Usage**:
    - `switchmon` - Does not take arguments.
  - *Defined in*: `modules/home/scripts/wm-controls/switchmon.nix`
