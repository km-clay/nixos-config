# Home-Manager Options

- **movOpts**

  - **homeFiles**
    - **enable**
      - Enables my declared files.
      - *Type*: Boolean
      - *Default*: `true`
      - *Defined in*: `modules/home/files.nix`

---

  - **envConfig**

    - **hyprlandConfig**
      - **enable**
        - Enables my custom Hyprland configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/hyprland.nix`
      - **monitorNames**
        - List of monitor names for my Hyprland configuration.
        - *Type*: List of Strings
        - *Default*: `[]`
        - *Defined in*: `modules/home/environment/hyprland.nix`
      - **workspaceLayout**
        - Workspace layout for Hyprland (e.g., dual monitor setups).
        - *Type*: String
        - *Default*: `"dualmonitor"`
        - *Defined in*: `modules/home/environment/hyprland.nix`

    - **userPkgs**
      - **enable**
        - Enables my default user packages.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/userpkgs.nix`

    - **stylixHomeConfig**
      - **enable**
        - Enables my Stylix Home-Manager options.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/stylix.nix`

    - **waybarConfig**
      - **enable**
        - Enables my custom Waybar configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/waybar.nix`

    - **gtkConfig**
      - **enable**
        - Enables my GTK configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/gtk.nix`

    - **spicetifyConfig**
      - **enable**
        - Enables my Spicetify configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/spicetify.nix`

    - **starshipConfig**
      - **enable**
        - Enables my Starship prompt configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/starship.nix`

    - **swayncConfig**
      - **enable**
        - Enables my SwayNC configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/environment/swaync.nix`

    - **zshConfig**
      - **shellAliases**
        - **enable**
          - Enables custom shell aliases.
          - *Type*: Boolean
          - *Default*: `true`
          - *Defined in*: `modules/home/environment/zsh/aliases.nix`
      - **envVariables**
        - **enable**
          - Enables custom environment variables for Zsh.
          - *Type*: Boolean
          - *Default*: `true`
          - *Defined in*: `modules/home/environment/zsh/env.nix`
      - **shellOptions**
        - **enable**
          - Enables custom shell options for Zsh.
          - *Type*: Boolean
          - *Default*: `true`
          - *Defined in*: `modules/home/environment/zsh/options.nix`
      - **extraConfig**
        - **enable**
          - Enables extra custom configuration for Zsh.
          - *Type*: Boolean
          - *Default*: `true`
          - *Defined in*: `modules/home/environment/zsh/extraconfig.nix`

---

  - **programConfigs**

    - **autojumpConfig**
      - **enable**
        - Enables my Autojump options.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/autojump.nix`

    - **btopConfig**
      - **enable**
        - Enables my Btop configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/btop.nix`

    - **cavaConfig**
      - **enable**
        - Enables my Cava configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/cava.nix`

    - **ezaConfig**
      - **enable**
        - Enables my Eza configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/eza.nix`

    - **firefoxConfig**
      - **enable**
        - Enables my Firefox configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/firefox.nix`

    - **fuzzelConfig**
      - **enable**
        - Enables my Fuzzel configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/fuzzel.nix`

    - **fzfConfig**
      - **enable**
        - Enables my FZF configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/fzf.nix`

    - **gitConfig**
      - **enable**
        - Enables my Git configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/git.nix`

    - **kittyConfig**
      - **enable**
        - Enables my Kitty configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/kitty.nix`

    - **yaziConfig**
      - **enable**
        - Enables my Yazi configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/yazi.nix`

    - **passConfig**
      - **enable**
        - Enables my Password-Store configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/password-store.nix`

    - **batConfig**
      - **enable**
        - Enables my Bat configuration.
        - *Type*: Boolean
        - *Default*: `true`
        - *Defined in*: `modules/home/programs/bat.nix`
