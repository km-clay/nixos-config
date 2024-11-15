{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
    pname = "pkg_maintenance_check";
    version = "1.0";
    src = ./.;
    buildPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/checkupdates.py <<- EOF
import json
import subprocess
import requests
def get_packages_by_maintainer(target_maintainer):
    try:
        nix_env_command = [
            "nix-env", "--meta", "--json", "-qaP"
        ]
        jq_query = (
            'to_entries[] | select(.value.meta.maintainers? // [] | '
            f'any(.github == "{target_maintainer}")) | .value'
        )
        result = subprocess.run(
            nix_env_command,
            capture_output=True,
            text=True,
            check=True
        )
        filtered_packages = subprocess.run(
            ["jq", "-r", "-c", jq_query],
            input=result.stdout,
            capture_output=True,
            text=True,
            check=True
        )
        return [json.loads(pkg) for pkg in filtered_packages.stdout.strip().split('\n') if pkg]
    except subprocess.CalledProcessError as e:
        print(f"Error running nix-env or jq: {e}")
        return []

def check_github_releases(maintained_packages):
    github_api_template = "https://api.github.com/repos/{owner}/{repo}/releases/latest"
    updates = []

    for package in maintained_packages:
        pname = package.get("pname", "unknown")
        repo_url = package.get("meta", {}).get("homepage", "")
        current_version = package.get("version", "unknown")

        if "github.com" in repo_url:
            owner_repo = repo_url.split("github.com/")[1].rstrip('/')
            owner, repo = owner_repo.split('/')
            api_url = github_api_template.format(owner=owner, repo=repo)

            response = requests.get(api_url)
            if response.status_code == 200:
                latest_release = response.json()
                latest_version = latest_release.get("tag_name", "").lstrip('v')
                if latest_version and latest_version != current_version:
                    updates.append({"pkg": pname, "version": latest_version})
                else:
                    print(f"{pname} is up to date.\n")
            else:
                print(f"Failed to check version for {pname} (HTTP {response.status_code}).\n")
        else:
            print(f"Skipping non-GitHub repository for {pname}.\n")
    return updates

def notify_updates(updates):
    if updates:
        update_string = '\n'.join([f"  {update['pkg']} -> {update['version']}" for update in updates])
        subprocess.run([
            "notify-send",
            "--icon=/home/pagedmov/.sysflake/assets/images/nixos-icon-generic.png",
            "Maintenance Update",
            f"Package updates found:\n{update_string}"
        ])
        subprocess.run(["aplay", "-q", "-N", "/home/pagedmov/.sysflake/assets/sound/login.wav"])

target_maintainer = "pagedMov"
maintained_packages = get_packages_by_maintainer(target_maintainer)

if maintained_packages:
    updates = check_github_releases(maintained_packages)
    notify_updates(updates)
else:
    print(f"No packages maintained by {target_maintainer} were found.")
EOF
    '';
    buildInputs = with pkgs; [ python3Packages.requests jq ];
    installPhase = ":";
}
