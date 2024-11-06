{ pkgs }:

pkgs.writeShellApplication {
  name = "icanhazip";
  runtimeInputs = with pkgs; [
    iproute2
    curl
    gawk
    coreutils
  ];
  text = ''
    if [ $# -eq 0 ]; then
      echo "Public IP: $(curl -s icanhazip.com -4)"
      ip route | awk '/default/ {print "Default Gateway: " $3} /src/ {print "Local IP: " $9}' | head -n 2
    else case $1 in
      "-p" ) echo "Public IP: $(curl -s icanhazip.com -4)";;
      "-d" ) ip route | awk '/default/ {print $3}';;
      "-l" ) ip route | awk '/src/ {print $9}';;
      * ) echo "Options: -p, -d or -l for public ip, default gateway, and local ip respectively"; echo "i.e. icanhazip -p"
      esac
    fi
  '';
}
