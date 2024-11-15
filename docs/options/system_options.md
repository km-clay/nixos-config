# System Options

- **sysEnv**
  - **issue**
    - **enable**
      - Enables my custom `/etc/issue` TTY splash screen.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/environment/issue.nix`

  - **sddmConfig**
    - **enable**
      - Enables my Catppuccin-SDDM configuration.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/environment/sddm.nix`

  - **stylixConfig**
    - **enable**
      - Enables Stylix for system theming.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/environment/stylix.nix`

  - **nixSettings**
    - **enable**
      - Enables my NixOS settings.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/environment/nix.nix`

---

- **hardwareCfg**
  - **networkModule**
    - **enable**
      - Enables my network configuration.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/hardware/network.nix`

  - **bootLoader**
    - **enable**
      - Enables my bootloader settings.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/hardware/bootloader.nix`

---

- **softwareCfg**
  - **gamingPkgs**
    - **enable**
      - Enables gaming-related packages.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/software/gaming/gaming_pkgs.nix`

  - **steamConfig**
    - **enable**
      - Enables my Steam configuration.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/software/gaming/steam.nix`

  - **sysPkgs**
    - **enable**
      - Installs my default system packages.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/software/packages.nix`

  - **sysProgs**
    - **enable**
      - Enables my system programs.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/software/programs.nix`

  - **sysServices**
    - **enable**
      - Enables system services.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/software/services.nix`

  - **virtConfig**
    - **enable**
      - Enables virtualization-related configuration.
      - *Type*: Boolean
      - *Default*: `false`
      - *Defined in*: `modules/sys/software/virtualization.nix`
