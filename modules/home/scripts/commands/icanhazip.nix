{ pkgs }:

pkgs.writeShellScriptBin "icanhazip" ''
  echo "Public IP: $(curl -s icanhazip.com -4)"
  ip route | awk '/default/ {print "Default Gateway: " $3} /src/ {print "Local IP: " $9}' | head -n 2
''
