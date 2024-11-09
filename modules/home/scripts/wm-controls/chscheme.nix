{ pkgs }:
pkgs.writeShellApplication {
  name = "chscheme";
  runtimeInputs = with pkgs; [ fzf coreutils ];
  text = ''
    selected_scheme=$(/usr/bin/env ls "$(nix-build '<nixpkgs>' -A base16-schemes)"/share/themes | \
        sed 's/\.yaml//g' | \
        fzf --preview "cat \"$(nix-build '<nixpkgs>' -A base16-schemes)/share/themes/{}.yaml\" | \
        while IFS=\": \" read -r key value; do \
            if [[ \$key =~ base0[0-9A-F] ]]; then \
                clean_value=\$(echo \"\$value\" | tr -d '\"'); \
                r=\$((16#\''${clean_value:0:2})); \
                g=\$((16#\''${clean_value:2:2})); \
                b=\$((16#\''${clean_value:4:2})); \
                printf \"\\033[48;2;%d;%d;%dm %-20s %s \\033[0m\\n\" \$r \$g \$b \$key \$clean_value; \
            fi; \
        done")

    if [[ -z "$selected_scheme" ]]; then
        echo "Aborting color scheme change."
        exit 1
    fi

    if ! echo "$selected_scheme" | xargs -I {} sed -i '/^[[:space:]]*scheme\s*=\s*"/s/"[^"]*"/"{}"/' "$FLAKEPATH"/modules/sys/environment/stylix.nix; then
        echo "Failed to change color scheme."
        exit 1
    fi

    echo "Successfully changed system color scheme. Rebuild now?"
    select choice in "Yes" "No"; do
        case $choice in
            "Yes")
                rebuild
                exit 0
                ;;
            "No")
                echo "Exiting..."
                exit 0
                ;;
        esac
    done
  '';
}
