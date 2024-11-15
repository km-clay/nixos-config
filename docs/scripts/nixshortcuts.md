# pagedMov's Nix Aliases

- **fetchfromgh**
  - **Description**:
    - Given a username and repo name like `someuser/somerepo`, generates a full `pkgs.fetchFromGitHub` call. Uses the most recent commit.
  - **Usage**:
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
  - *Defined in*: `modules/home/scripts/nix/fetchfromgh.nix`

---

- **garbage-collect**
  - **Description**:
    - Runs the Nix garbage collector and also deletes all files in `.local/share/Trash`.
  - **Usage**:
    - `garbage-collect` - Does not take any arguments.
  - *Defined in*: `modules/home/scripts/nix/garbage-collect.nix`

---

- **nsp**
  - **Description**:
    - Simple alias for `nix-shell -p`.
  - **Usage**:
    - `nsp <package name>`
  - **Example**:
    - `nsp hello`
  - *Defined in*: `modules/home/scripts/nix/nsp.nix`

---

- **rebuild**
  - **Description**:
    - Combines `nh os switch` and `nh home switch` into a single command.
  - **Usage**:
    - `rebuild -h` - Runs `nh home switch -c <currenthostname> $FLAKEPATH`
    - `rebuild -s` - Runs `nh os switch -H <currenthostname> $FLAKEPATH`
    - `rebuild -a` - Runs both of the above commands.
    - Adding `n` before any flag (e.g., `rebuild -na`) performs a dry run.
  - *Defined in*: `modules/home/scripts/nix/rebuild.nix`
