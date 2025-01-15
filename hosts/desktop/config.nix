{ pkgs, username, ... }:

let rsh = pkgs.rustPlatform.buildRustPackage {
  pname = "rsh";
  version = "0.0.1";
  buildType = "debug";

  src = ../../overlay/pkgs/rsh/rsh;

  cargoHash = "sha256-8Lb7AohSah2A7pcoT2JPDgza0LfIyD897yj4QHNklDw=";
  cargoLock = {
    lockFile = ../../overlay/pkgs/rsh/rsh/Cargo.lock;
  };

  buildInputs = [ ];

  meta = {
    description = "Modern shell scripting";
    homepage = "https://github.com/pagedMov/rsh";
    license = pkgs.lib.licenses.gpl3;
    maintainers = with pkgs.lib.maintainers; [ pagedMov ];
  };
  passthru = {
    shellPath = "/bin/rsh";
  };
};
in
{
  imports = [ ./hardware.nix ];

  # My module options
  movOpts = {
    sysEnv = {
      issue.enable = true;
      sddmConfig.enable = false;
      stylixConfig.enable = true;
      nixSettings.enable = true;
      #consoleSettings.enable = true;
    };
    hardwareCfg = {
      networkModule.enable = true;
      bootLoader.enable = true;
    };
    softwareCfg = {
      gamingPkgs.enable = true;
      steamConfig.enable = true;
      sysPkgs.enable = true;
      sysProgs.enable = true;
      sysServices.enable = true;
      virtConfig.enable = true;
    };
  };

  environment = {
    variables = { PATH = "${pkgs.clang-tools}/bin:$PATH"; };
    shells = [ rsh pkgs.zsh pkgs.bash ];
  };

  users = {
    groups.persist = { };
    users = {
      root.initialPassword = "1234";
      ${username} = {
        isNormalUser = true;
        initialPassword = "1234";
        shell = pkgs.elvish;
        extraGroups = [ "input" "wheel" "persist" "libvirtd" ];
      };
    };
  };
  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: /etc/profiles/per-user/${username}/bin/rebuild
  '';
  nix.settings.allowed-users = [ "${username}" ];

  time.timeZone = "America/New_York";
}
