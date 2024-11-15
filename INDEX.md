# Index of Configuration Files

This document provides an overview of the directories and Nix files in my configuration, along with a brief description of their purpose.

---

## Assets
- Contains resources used by the configuration, such as images, sound effects, and wallpapers.

### Subdirectories:
- **images/**
  - General images like icons and logos.
- **screens/**
  - Screenshots of the desktop environment and toolbelt demos.
- **sound/**
  - Sound effects for terminal interactions and system events.
- **wallpapers/**
  - Wallpapers used for the desktop environment.

---

## Hosts
- Machine-specific configurations.

### Subdirectories:
- **desktop/**:
  - Configuration for the desktop machine.
  - Files: `config.nix`, `hardware.nix`, `home.nix`
- **laptop/**:
  - Configuration for the laptop.
  - Files: `config.nix`, `hardware.nix`, `home.nix`
- **server/**:
  - Configuration for the server.
  - Files: `config.nix`, `hardware.nix`, `home.nix`
- **installer/**:
  - NixOS installer configuration.
  - Files: `default.nix`, `disko-ext4-singledisk.nix`

---

## Modules
- Main modules for defining home and system-level configurations.

### Subdirectories:
- **home/**:
  - Modules for user environments, programs, and custom scripts.
  - **Subdirectories**:
    - **environment/**: Configures desktop environment components like Hyprland, Waybar, and GTK.
      - Files: `hyprland.nix`, `waybar.nix`, `gtk.nix`
    - **programs/**: Configures user programs like Firefox, Kitty, and autojump.
      - Files: `firefox.nix`, `kitty.nix`, `autojump.nix`
    - **scripts/**: Defines custom commands, Nix aliases, and window manager controls.
      - **Subdirectories**:
        - **commands/**: My CLI scripts.
        - **nix/**: Nix-specific utilities.
        - **wm-controls/**: Custom controls for Hyprland.

- **server/**:
  - Server-specific modules, including Jellyfin and CDN configurations. Still under construction.
  - Files: `jellyfin.nix`, `cdn/default.nix`

- **sys/**:
  - Modules for system-level configurations, including hardware, software, and environment settings.
  - **Subdirectories**:
    - **hardware/**: Configures hardware components like the bootloader and network.
      - Files: `bootloader.nix`, `network.nix`
    - **software/**: Manages installed packages, programs, and services.
      - Files: `packages.nix`, `services.nix`
    - **sysenv/**: Configures system environment settings.
      - Files: `issue.nix`, `sddm.nix`

---

## Overlay
- Custom Nix overlays for my derivations and utilities.

### Subdirectories:
- **breezex-cursor/**: Package for custom cursor themes.
  - Files: `package.nix`
- **check_updates/**: Script for checking package updates.
  - Files: `package.nix`
- Root file: `overlay.nix`

---

## Additional Notes
- **Assets** contains resources like images and sounds used in the configuration.
- **Modules** contain the logic and settings for both user-level and system-level configurations.
- **Hosts** provide machine-specific overrides for desktop, laptop, and server setups.
- **Overlay** adds customizations to the Nix package set.
