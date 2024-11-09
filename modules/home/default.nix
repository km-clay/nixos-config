{ env, inputs, nixpkgs, config, self, username, host, lib, ... }: {
  imports = [ ./programs ./environment ./scripts ./files.nix ];
}
