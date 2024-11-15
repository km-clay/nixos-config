# pagedMov's Custom Command Scripts

- **icanhazip**
  - **Description**:
    - Leverages `ip` and `icanhazip.com` to return relevant IP information for the current machine.
  - **Usage**:
    - `icanhazip` - Returns public IP, local IP, and default gateway.
    - `icanhazip -p` - Returns only public IP.
    - `icanhazip -l` - Returns only local IP.
    - `icanhazip -d` - Returns only default gateway.
  - *Defined in*: `modules/home/scripts/commands/icanhazip.nix`

---

- **invoke**
  - **Description**:
    - Leverages `nix run` to run any command once. Works with arguments.
  - **Usage**:
    - `invoke <command>`
  - **Example**:
    - `invoke hello`
  - *Defined in*: `modules/home/scripts/commands/invoke.nix`

---

- **runbg**
  - **Description**:
    - Runs a command and detaches the process from the shell silently. Works with arguments.
    - Credit to [Frost-Phoenix](https://github.com/Frost-Phoenix) for writing this script.
  - **Usage**:
    - `runbg <command> <args>`
  - **Example**:
    - `runbg waybar`
  - *Defined in*: `modules/home/scripts/commands/runbg.nix`

---

- **toolbelt**
  - **Description**:
    - Opens a fuzzyfinder window with some useful utilities.
    - Meant to be used with the `Super + P` bind defined in `hyprland.nix`, and not invoked directly from the shell.
  - *Defined in*: `modules/home/scripts/commands/toolbelt.nix`

---

- **viconf**
  - **Description**:
    - Searches the directory held in the `$FLAKEPATH` environment variable for a given Nix file or directory name.
    - Opens the file in Neovim, or if there are multiple matches, opens a fuzzyfinder window to allow you to choose one.
  - **Usage**:
    - `viconf <part of path or filename>`
  - **Examples**:
    - `viconf hyprland` - Opens `$FLAKEPATH/modules/home/environment/hyprland.nix`.
    - `viconf sys` - Opens a fuzzyfinder window containing all Nix files in `modules/sys` and its subdirectories.
    - `viconf config` - Opens a fuzzyfinder window containing all Nix files called `config.nix`.
    - `viconf scripts/def` - Opens `$FLAKEPATH/modules/home/scripts/default.nix`.
  - *Defined in*: `modules/home/scripts/commands/viconf.nix`

---

- **vipkg**
  - **Description**:
    - Searches the `pkgs` directory from the Nixpkgs GitHub repository.
    - Works almost identically to `viconf` with a few tweaks to accommodate the different directory structure.
    - Useful for overriding a package's build attributes or searching for a package name.
  - **Usage**:
    - `vipkg <part of package name>`
  - **Example**:
    - `vipkg neofetch` - Opens `nixpkgs/pkgs/tools/misc/neofetch/default.nix`.
  - *Defined in*: `modules/home/scripts/commands/vipkg.nix`
