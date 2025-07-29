{ slash, pkgs, username, ... }:

let
  kickstartServer =
    let
      libsrcds = pkgs.stdenv.mkDerivation {
        name = "libsrcds";
        src = pkgs.fetchFromGitHub {
          owner = "km-clay";
          repo = "sourceds-libraries";
          rev = "08d12c91af664ffd103482ae1a24714222bef2df";
          hash = "sha256-EFXBhqZEkBNpYjNuG7oTZLgfjqM5G+nLb7e/qeN1Tvw=";
        };
        installPhase = ''
          mkdir -p $out/lib
          cp ./* $out/lib
        '';
      };
      startTf2Server = pkgs.writeShellScript "start-srv.sh" ''
    set -euo pipefail
    export HOME=/home/tf2
    export LD_LIBRARY_PATH=/usr/lib:/usr/lib32
    mkdir -p "$HOME/tf2server"
    mkdir -p "$HOME/tf2server"

    steamcmd +force_install_dir "$HOME/tf2server" \
       +login anonymous \
       +app_update 232250 validate \
       +quit

    cd "$HOME/tf2server"

    ln -sf "$HOME/.steam/steam/linux64" "$HOME/.steam/sdk64"
    ln -sf "$HOME/.steam/steam/linux32" "$HOME/.steam/sdk32"

    exec ./srcds_run -game tf -console -port 25565 +map cp_dustbowl \
         +ip 10.233.1.2 -norestart \
         +sv_setsteamaccount 8862FD4B30F401036B8AAC6A7FE6B123
      '';
    in
      pkgs.buildFHSEnv {
        name = "srcds-env";
        targetPkgs = pkgs: with pkgs; [
          steamcmd
          glibc
          zlib
          curl
          libuuid
          openssl
          libnl
          libsrcds

            # Optional: link compat
            stdenv.cc.cc.lib
          ];
          multiPkgs = pkgs: with pkgs.pkgsi686Linux; [
            glibc
            zlib
            ncurses5
            libuuid
            alsa-lib
            libxcrypt-legacy
            gcc
          ];
          multiArch = true;
          runScript = "${startTf2Server}";

        };
in
{
  networking = {
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface =  "enp8s0";
    };
  };
  containers.tf2server = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    config = {
      imports = [ ];
      nixpkgs.config.allowUnfree = true;


      services.openssh.enable = true;
      users.users.root.password = "root"; # For quick login, remove in prod

      environment.systemPackages = with pkgs; [
        steamcmd
        steam-run
        coreutils
        wget
        unzip
        bash
        nix
        coreutils
        vim
      ];

      users.users.tf2server = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.bash;
        extraGroups = [ "wheel" ];
      };

      systemd.services.tf2server = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${kickstartServer}/bin/srcds-env";
        };
      };

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Optional: open ports on the container
      networking.firewall.allowedTCPPorts = [ 25565 ];
      networking.firewall.allowedUDPPorts = [ 25565 27005 27015 27020 ];

      system.stateVersion = "25.11"; # or your NixOS version
    };
  };
}
