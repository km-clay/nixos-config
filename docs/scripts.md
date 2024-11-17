# pagedMov's scripts

---

This document contains information about the scripts I've written for this configuration. All of the scripts listed here are
included in my nixpkgs overlay as custom packages, and these packages are declared in the configuration in the file
`overlay/env/userpkgs.nix`

- **icanhazip**
  - *Description*:
    - Leverages `ip` and `icanhazip.com` to return relevant IP information for the current machine.
  - *Usage*:
    - `icanhazip` - Returns public IP, local IP, and default gateway.
    - `icanhazip -p` - Returns only public IP.
    - `icanhazip -l` - Returns only local IP.
    - `icanhazip -d` - Returns only default gateway.
  - *Defined in*: `overlay/scripts/commands/icanhazip.nix`

---

- **invoke**
  - *Description*:
    - Leverages `nix run` to run any command once. Works with arguments.
  - *Usage*:
    - `invoke <command>`
  - **Example**:
    - `invoke hello`
  - *Defined in*: `overlay/scripts/commands/invoke.nix`

---

- **runbg**
  - *Description*:
    - Runs a command and detaches the process from the shell silently. Works with arguments.
    - Credit to [Frost-Phoenix](https://github.com/Frost-Phoenix) for writing this script.
  - *Usage*:
    - `runbg <command> <args>`
  - **Example**:
    - `runbg waybar`
  - *Defined in*: `overlay/scripts/commands/runbg.nix`

---

- **git-compose**
  - *Description*:
    - To be used in a git repository. Opens an interactive neovim session containing all currently uncommitted changes. Allows you to group files together and give individual commit messages to each group of files. Automatically creates commits for the file groups with the given commit messages.
  - *Usage*:
    - `git-compose (inside of a git repository)`
  - *Defined in*: `overlay/scripts/commands/git-compose.nix`

---

- **toolbelt**
  - *Description*:
    - Opens a fuzzyfinder window with some useful utilities.
    - Meant to be used with the `Super + P` bind defined in `hyprland.nix`, and not invoked directly from the shell.
  - *Defined in*: `overlay/scripts/commands/toolbelt.nix`

---

- **viconf**
  - *Description*:
    - Searches the directory held in the `$FLAKEPATH` environment variable for a given Nix file or directory name.
    - Opens the file in Neovim, or if there are multiple matches, opens a fuzzyfinder window to allow you to choose one.
  - *Usage*:
    - `viconf <part of path or filename>`
  - **Examples**:
    - `viconf hyprland` - Opens `$FLAKEPATH/overlay/environment/hyprland.nix`.
    - `viconf sys` - Opens a fuzzyfinder window containing all Nix files in `modules/sys` and its subdirectories.
    - `viconf config` - Opens a fuzzyfinder window containing all Nix files called `config.nix`.
    - `viconf scripts/def` - Opens `$FLAKEPATH/overlay/scripts/default.nix`.
  - *Defined in*: `overlay/scripts/commands/viconf.nix`

---

- **vipkg**
  - *Description*:
    - Searches the `pkgs` directory from the Nixpkgs GitHub repository.
    - Works almost identically to `viconf` with a few tweaks to accommodate the different directory structure.
    - Useful for overriding a package's build attributes or searching for a package name.
  - *Usage*:
    - `vipkg <part of package name>`
  - **Example**:
    - `vipkg neofetch` - Opens `nixpkgs/pkgs/tools/misc/neofetch/default.nix`.
  - *Defined in*: `overlay/scripts/commands/vipkg.nix`

---

- **fetchfromgh**
  - *Description*:
    - Given a username and repo name like `someuser/somerepo`, generates a full `pkgs.fetchFromGitHub` call. Uses the most recent commit.
  - *Usage*:
    - `fetchfromgh someuser/somerepo`
  - **Example**:
    - `fetchfromgh pagedMov/nixos-config`
      - Returns:
        ```
        src = pkgs.fetchFromGitHub {
          owner = "pagedMov";
          repo = "nixos-config";
          rev = "fcf19c65971c667f67abf57bcaf88be410fb0759";
          hash = "sha256-z+3E+ueSd2QNqtrbBKt8bwIfboPCXSUrGn690Hc/kl0=";
        };
        ```
  - *Defined in*: `overlay/scripts/nix/fetchfromgh.nix`

---

- **garbage-collect**
  - *Description*:
    - Runs the Nix garbage collector and also deletes all files in `.local/share/Trash`.
  - *Usage*:
    - `garbage-collect` - Does not take any arguments.
  - *Defined in*: `overlay/scripts/nix/garbage-collect.nix`

---

- **nsp**
  - *Description*:
    - Simple alias for `nix-shell -p`.
  - *Usage*:
    - `nsp <package name>`
  - **Example**:
    - `nsp hello`
  - *Defined in*: `overlay/scripts/nix/nsp.nix`

---

- **rebuild**
  - *Description*:
    - Combines `nh os switch` and `nh home switch` into a single command.
  - *Usage*:
    - `rebuild -h` - Runs `nh home switch -c <currenthostname> $FLAKEPATH`
    - `rebuild -s` - Runs `nh os switch -H <currenthostname> $FLAKEPATH`
    - `rebuild -a` - Runs both of the above commands.
    - Adding `n` before any flag (e.g., `rebuild -na`) performs a dry run.
  - *Defined in*: `overlay/scripts/nix/rebuild.nix`

---

*Note*: None of the following scripts are meant to be invoked directly in the terminal and are primarily used as helpers for other scripts. However, they are documented here in case you wish to use them in your own scripts.

---

- **chscheme**
  - *Description*:
    - Opens an `fzf` menu containing all of the color schemes available in the `base16schemes` package from Nixpkgs.
    - The `fzf` preview shows the colors so you can see them in your terminal before choosing one.
  - *Usage*:
    - `chscheme` - Does not take arguments.
  - *Defined in*: `overlay/scripts/wm-controls/chscheme.nix`

---

- **chpaper**
  - *Description*:
    - Opens an `fzf` menu containing all wallpapers in `$FLAKEPATH/assets/wallpapers`.
    - The `fzf` preview shows the image file the user is hovering over.
  - *Usage*:
    - `chpaper` - Does not take arguments.
  - *Defined in*: `overlay/scripts/wm-controls/chpaper.nix`

---

- **keyring**
  - *Description*:
    - Opens an `fzf` menu containing all directories/files in `~/.password-store`.
    - Selecting an entry uses `pass -c` to copy it to the clipboard.
    - Temporarily pauses the clipboard history daemon to ensure the password is not added to clipboard history.
    - Automatically clears the password from the clipboard after 10 seconds unless overwritten.
  - *Usage*:
    - `keyring` - Does not take arguments.
  - *Defined in*: `overlay/scripts/wm-controls/keyring.nix`

---

- **mkscreenshots**
  - *Description*:
    - Switches to workspace 4 (if empty) and takes screenshots showcasing the desktop environment.
    - Saves the screenshots to `$FLAKEPATH/assets/screens`, overwriting the old ones.
    - Updates `README.md` to include the commit hash of the current screenshots.
  - *Usage*:
    - `mkscreenshots` - Does not take arguments. Only runs if workspace 4 has no windows.
  - *Defined in*: `overlay/scripts/wm-controls/mkscreenshots.nix`

---

- **moveonscreen**
  - *Description*:
    - Uses `hyprctl` to move the currently active floating window relative to the cursor.
    - Prevents the window from moving outside the screen bounds.
    - Often used with `toolbelt` for smooth window movements.
  - *Usage*:
    - `moveonscreen` - Moves the window to the cursor's position, anchored at the top-left corner.
    - `moveonscreen --center` - Moves the window to the cursor's position, anchored at the center of the window.
  - *Defined in*: `overlay/scripts/wm-controls/moveonscreen.nix`

---

- **s_check**
  - *Description*:
    - Tests whether `$SOUNDS_ENABLED` is set to `0` or `1`.
    - Does not return anything except the status code from the test.
    - *Note*: This does not work as a Zsh alias for unknown reasons.
  - *Usage*:
    - `s_check` - Does not take arguments.
  - *Defined in*: `overlay/scripts/wm-controls/switchmon.nix`

---

- **switchmon**
  - *Description*:
    - Uses `hyprctl` to switch focus between two monitors.
    - Only supports setups with two monitors.
  - *Usage*:
    - `switchmon` - Does not take arguments.
  - *Defined in*: `overlay/scripts/wm-controls/switchmon.nix`

---

- **color-commit**
  - *Description*:
    - Colorizes the output of `git commit` if piped into it via stdin
  - *Usage*:
    - `git commit -m "message" | color-commit`
  - *Defined in*: `overlay/scripts/misc/color-commit.nix`
