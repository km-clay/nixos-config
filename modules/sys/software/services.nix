{...}: {
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };
    udev.enable = true;
    dbus.enable = true;
    mullvad-vpn.enable = true;
    blueman.enable = true;
    openssh = {
      enable = true;
      allowSFTP = true;
    };
  };
}
