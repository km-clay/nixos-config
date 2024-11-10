{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
    pname = "pkg_maintenance_check";
    version = "1.0";
    src = ./.;
    buildPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/checkupdates.py <<- EOF
import os, re, json, requests, subprocess
flakePath = os.getenv('FLAKEPATH')
def nix_eval(expr):
    try:
        result = subprocess.run(
            ["nix", "eval", "--json", expr],
            capture_output=True,
            text=True,
            check=True)
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running 'nix eval' for {expr}: {e}")
        return {}
packages = nix_eval(f"{flakePath}#pkgs.myPkgs")
target_maintainer = 'pagedMov'
maintained_packages = []
for pname in packages.keys():
    maintainers_info = nix_eval(f"{flakePath}#pkgs.myPkgs.{pname}.meta.maintainers")
    for maintainer in maintainers_info:
        if maintainer.get('github') == target_maintainer:
            # Collect relevant package details
            version = nix_eval(f"{flakePath}#pkgs.myPkgs.{pname}.version") or "unknown"
            repo_url = nix_eval(f"{flakePath}#pkgs.myPkgs.{pname}.meta.homepage") or ""
            maintained_packages.append({
                'pname': pname,
                'version': version,
                'repo': repo_url,
                'maintainers': maintainers_info
            })
            break
print(json.dumps(maintained_packages, indent=2))
github_api_template = "https://api.github.com/repos/{owner}/{repo}/releases/latest"
updates = []
for package in maintained_packages:
    repo_url = package["repo"]
    current_version = package["version"]
    if "github.com" in repo_url:
        owner_repo = repo_url.split("github.com/")[1].rstrip('/')
        owner, repo = owner_repo.split('/')
        api_url = github_api_template.format(owner=owner, repo=repo)
        response = requests.get(api_url)
        if response.status_code == 200:
            latest_release = response.json()
            latest_version = latest_release.get("tag_name", "").lstrip('v')
            if latest_version and latest_version != current_version:
                updates.append({"pkg": package["pname"], "version": latest_version})
            else:
                print(f"{package['pname']} is up to date.\n")
        else:
            print(f"Failed to check version for {package['pname']} (HTTP {response.status_code}).\n")
    else:
        print(f"Skipping non-GitHub repository for {package['pname']}.\n")
if updates:
    update_string = '\n'.join([f"  {update['pkg']} -> {update['version']}" for update in updates])
    subprocess.run(["notify-send", "--icon=/home/pagedmov/.sysflake/assets/images/nixos-icon-generic.png",
                    "Maintenance Update", f"Package updates found:\n{update_string}"])
    subprocess.run(["aplay", "-q", "-N", "/home/pagedmov/.sysflake/assets/sound/login.wav"])
EOF
    '';
    buildInputs = with pkgs; [ python3Packages.requests ];
    installPhase = ":";
}
