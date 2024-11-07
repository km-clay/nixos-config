{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellApplication {
  name = "fetchfromgh";
  runtimeInputs = [
    pkgs.nix-prefetch-scripts
  ];
  text = ''
    if [ $# -ne 1 ] || ! echo "$1" | grep -qE "[A-Za-z0-9_-]+/[A-Za-z0-9_-]+"; then
      echo "Usage: fetchfromgh someuser/somerepo"
      echo "     - i.e. fetchfromgh pagedMov/nixos-config"
      exit 1
    fi

  if ! curl -s -o /dev/null -w "%{http_code}" "https://github.com/$1" | grep -q "200"; then
    echo "Couldn't find that repository, curl returned 404."
    exit 1
  fi

    json=$(nix-prefetch-git --quiet "https://github.com/$1")

    url=$(echo "$json" | jq '.url' | tr -d '"')
    owner=$(echo "$url" | awk -F'/' '{print $(NF-1)}')
    repo=$(echo "$url" | awk -F'/' '{print $NF}')
    rev=$(echo "$json" | jq '.rev' | tr -d '"')
    hash=$(echo "$json" | jq '.hash' | tr -d '"')

    output="\
    src = pkgs.fetchFromGitHub {
      owner = \"$owner\";
      repo = \"$repo\";
      rev = \"$rev\";
      hash = \"$hash\";
    };
    "
    echo "$output"
  '';
}
