{lib, config, nur, username, self, pkgs, ... }: {
  options = {
    movOpts.firefoxConfig.enable = lib.mkEnableOption "enables my firefox configuration";
  };
  config = lib.mkIf config.movOpts.firefoxConfig.enable {
    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "always"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"		isDefault = true;
      };
      profiles.${username} = {
        name = "${username}";
        bookmarks = [
          {
            name = "Nix Sites";
            toolbar = true;
            bookmarks = [
              {
                name = "NixOS Wiki";
                url = "https://nixos.wiki/wiki/Main_Page";
              }
              {
                name = "Nixpkgs Reference Manual";
                url = "https://nixos.org/manual/nixpkgs/stable/";
              }
              {
                name = "NixOS Manual";
                url = "https://nixos.org/manual/nixos/stable/";
              }
              {
                name = "NixOS Options";
                url = "https://search.nixos.org/options";
              }
              {
                name = "Home Manager Options";
                url = "https://home-manager-options.extranix.com/";
              }
              {
                name = "Nixpkgs Package Search";
                url = "https://search.nixos.org/packages";
              }
              {
                name = "Noogle - Nixpkgs Function Docs";
                url = "https://noogle.dev";
              }
              {
                name = "Nixvim Docs";
                url = "https://nix-community.github.io/nixvim/";
              }
            ];
          }
          {
            name = "Rust Manual";
            url = "https://doc.rust-lang.org/book/ch01-03-hello-cargo.html";
          }
          {
            name = "ChatGPT";
            url = "https://chatgpt.com/";
          }
          {
            name = "DataAnnotation";
            url = "https://app.dataannotation.tech/users/sign_in";
          }
          {
            name = "Nerd Fonts Cheatsheet";
            url = "https://www.nerdfonts.com/cheat-sheet";
          }
        ];
        extraConfig = ''
           "browser.startup.homepage" = "${self}/glasshouse-desktop/home/firefox/homepage.html";
           "browser.active_color" = "#EE0000";
           "browser.active_color.dark" = "#FF6666";
           "browser.anchor_color" = "#0000EE";
           "browser.anchor_color.dark" = "#8C8CFF";
           "browser.display.background_color" = "#FFFFFF";
           "browser.display.background_color.dark" = "#1C1B22";
           "browser.display.document_color_use" = "1";
           "browser.display.foreground_color" = "#000000";
           "browser.display.foreground_color.dark" = "#FBFBFE";
           "browser.display.suppress_canvas_background_image_on_forced_colors" = "true";
           "browser.display.use_system_colors" = "false";
           "browser.newtabpage.activity-stream.newNewtabExperience.colors" = "#0090ED,#FF4F5F,#2AC3A2,#FF7139,#A172FF,#FFA437,#FF2A8A";
           "browser.theme.colorway-closet" = "true";
           "browser.theme.colorway-migration" = "true";
           "browser.theme.windows.accent-color-in-tabs.enabled" = "false";
           "browser.visited_color" = "#551A8B";
           "browser.visited_color.dark" = "#FFADFF";
           "browser.newtabpage.pinned" = [{
          title = "Homepage";
          url = "${self}/glasshouse-desktop/home/firefox/homepage.html";
           }];
           "devtools.defaultColorUnit" = "authored";
           "editor.background_color" = "#FFFFFF";
           "editor.use_custom_colors" = "false";
        '';
      };
    };
  };
}
