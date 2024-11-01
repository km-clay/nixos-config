{
  config,
  inputs,
  scheme,
  wallpaper,
  username,
  ...
}: {
  imports = [
    ./services.nix
    ../sys/software/nixvim
  ];
}
