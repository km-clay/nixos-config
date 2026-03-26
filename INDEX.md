# Index of Configuration Files

This document provides an overview of the directories and Nix files in this configuration, along with a brief description of their purpose.

---

## flake.nix
Entry point. Defines inputs (nixpkgs, hyprland, home-manager, stylix, nixvim, shed, etc.) and outputs. Host configurations are built via `movLib.foldHosts`, and exported outputs (modules, packages, devShells) are defined in the `exports/` directory.

---

## lib/
Helper functions and abstractions for the configuration.

- **default.nix** - Defines `movLib` (shared helpers), `mkHost`, `mkOverrideOption`, and `foldHosts`.
- **mk_host.nix** - Constructs NixOS and Home Manager configurations for a given host. Takes `specialArgs`, `pkgs`, modules, and overlays.

---

## hosts/
Machine-specific configurations. Each host has a `config.nix` (NixOS), `home.nix` (Home Manager), and `hardware.nix` (hardware-configuration).

- **baseconfig.nix** - Shared NixOS base for all hosts. Sets up boot, shell, users, and enables hardware/sysenv module options via `lib.mkDefault`.
- **basehome.nix** - Shared Home Manager base for all hosts. Sets username, homeDirectory, stateVersion.
- **desktop/** - `brinstar` host (desktop machine).
- **laptop/** - `kraid` host (laptop).
- **work/** - `tourian` host (work machine).

---

## exports/
Flake outputs split into separate files for organization.

- **default.nix** - Aggregates all exports.
- **modules.nix** - `homeModules.default`: a reusable Home Manager module that can be imported from other flakes. Defaults to cli profile with overridable username/homeDirectory.
- **packages.nix** - `packages.x86_64-linux.dev-home`: a pre-built Home Manager activation package for testing.
- **shells.nix** - `devShells.x86_64-linux.default`: a dev shell with nixvim and CLI tools from the home config.

---

## modules/home/
Home Manager modules. All options are opt-in (`mkEnableOption`, default false). Profiles enable groups of options.

- **default.nix** - Imports programs, environment, files, and profile modules.
- **files.nix** - Home file management (dotfiles, XDG config files).

### modules/home/profiles/
Thin layers that enable groups of home module options.

- **options.nix** - Declares `movOpts.homeConfig.profiles` and `enableProfiles` options.
- **cli.nix** - Enables CLI tools: autojump, bat, btop, eza, fzf, git, yazi, pass, starship, zsh config, shed config. All programs and configurations enabled by this profile are suitable for headless environments.
- **graphical.nix** - Enables graphical tools: kitty, fuzzel, hyprland, waybar, stylix, gtk, swaync, paperd, user services.

### modules/home/programs/
User program configurations. Each gated behind `movOpts.programConfigs.<name>.enable`.

- **default.nix** - Declares enable options and gates imports via `lib.mkIf`.
- **autojump.nix**, **bat.nix**, **btop.nix**, **cava.nix**, **eza.nix**, **fuzzel.nix**, **fzf.nix**, **git.nix**, **kitty.nix**, **password-store.nix**, **yazi.nix** - Individual program configs.
- **nixvim/** - Neovim configuration via nixvim. Contains `default.nix`, `autocmd.nix`, `keymaps.nix`, `options.nix`, and `plugins/` with individual plugin configs.

### modules/home/environment/
Desktop environment and shell configurations. Each gated behind `movOpts.envConfig.<name>.enable`.

- **default.nix** - Declares enable options and gates imports.
- **hyprland.nix** - Hyprland window manager config.
- **waybar.nix** - Waybar status bar config.
- **spicetify.nix** - Spotify customization via spicetify-nix.
- **starship.nix** - Starship prompt config.
- **stylixhome.nix** - Stylix theming for Home Manager.
- **gtk.nix** - GTK theme settings.
- **swaync.nix** - Sway notification center config.
- **userpkgs.nix** - Default user packages.
- **userservices-cli.nix** - Headless user systemd services.
- **userservices-graphical.nix** - Graphical user systemd services (swww, kitty sounds).
- **paperd/** - Paperd wallpaper daemon (`default.nix`, `paperd_script.nix`, `theme_builder.nix`).
- **zsh/** - Zsh config split into `aliases.nix`, `env.nix`, `options.nix`, `extraconfig.nix`.
- **shed/** - Shed shell config split into `aliases.nix`, `env.nix`, `options.nix`, `extraconfig.nix`, `functions.nix`, `autocmd.nix`, `keymaps.nix`, `complete.nix`.

---

## modules/sys/
NixOS system-level modules.

- **default.nix** - Imports hardware, software, and sysenv submodules.

### modules/sys/hardware/
Hardware configuration. Options gated behind `movOpts.hardwareCfg.<name>.enable`.

- **default.nix** - Declares enable options and gates imports.
- **bootloader.nix** - Bootloader (systemd-boot) config.
- **network.nix** - NetworkManager config.
- **kernel.nix** - Kernel module config.
- **powerprofiles.nix** - Power profiles daemon.
- **input.nix** - Input device settings (always imported).

### modules/sys/software/
System software. Uses a profile system: profiles flip enable flags, packages are gated behind those flags.

- **default.nix** - Declares `movOpts.softwareCfg.<name>.enable` options and gates package imports.

#### modules/sys/software/profiles/
Standalone modules that enable groups of software options based on `enableProfiles` list.

- **options.nix** - Declares `movOpts.softwareCfg.profiles` and `enableProfiles` options.
- **base.nix** - Enables `basePackages`.
- **desktop.nix** - Enables `desktopPackages`.
- **dev.nix** - Enables `devPackages`.
- **gaming.nix** - Enables `gamingPackages`.
- **virt.nix** - Enables `virtPackages`.

#### modules/sys/software/packages/
Actual package/service/program definitions for each category.

- **base.nix** - Core packages (git, gcc, vim, nix tooling), zsh, gnupg, keyd, openssh, SSH keys.
- **desktop.nix** - Wayland/Hyprland stack, audio (pipewire), display tools, nix-ld, blueman, mullvad.
- **dev.nix** - Development SDKs (.NET, Python, ffmpeg, cmake, openssl).
- **gaming.nix** - Emulators, prismlauncher, Steam with proton-ge-bin.
- **virt.nix** - libvirtd, virt-manager, spice/USB redirection.

### modules/sys/sysenv/
System environment settings. Options gated behind `movOpts.sysEnv.<name>.enable`.

- **default.nix** - Declares enable options and gates imports.
- **console.nix** - Locale and console font settings (self-contained module with own option).
- **issue.nix** - Custom `/etc/issue` TTY splash.
- **nix.nix** - Nix daemon settings.
- **stylix.nix** - Stylix theming for NixOS.
- **sddm.nix** - SDDM display manager config.

---

## overlay/
Custom Nix overlays adding packages and scripts to the package set.

- **overlay.nix** - Main overlay, imports packages and scripts.
- **pkgs/** - Custom package derivations:
  - **billy-font/** - Custom font.
  - **breezex-cursor/** - Custom cursor theme.
  - **noto-sans-jp/** - Japanese font.
  - **slash/** - Slash utility.
  - **zsh-fzf-tab/** - Zsh fzf-tab plugin.
- **scripts/** - Custom shell scripts exposed as packages:
  - **commands/** - CLI tools (git-compose, invoke, runbg, splash, toolbelt, viconf, vipkg, icanhazip).
  - **misc/** - Utilities (color-commit, mntstack).
  - **nix/** - Nix helpers (rebuild, garbage-collect, templates).
  - **wm-controls/** - Hyprland utilities (chpaper, chscheme, keyring, mkscreenshots, moveonscreen, playshellsound, s_check, switchmon).

---

## assets/
Resources used by the configuration: images, screenshots, sound effects, and wallpapers.
