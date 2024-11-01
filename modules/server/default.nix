{
  config,
  inputs,
  scheme,
  wallpaper,
  username,
  host,
  ...
}: {
  imports = [
    ../sys/software/nixvim
    ../sys/hardware/bootloader.nix
    ./services.nix
    ./home.nix
    ./packages.nix
  ];
}
