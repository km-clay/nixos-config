{ pkgs, self, ... }:

let
  check_updates = pkgs.stdenv.mkDerivation {
    pname = "pkg_maintenance_check";
    version = "1.0";
    src = ./.;
    buildPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/checkupdates.py <<- EOF
import os, re, json, requests, subprocess
root_dir = '/home/pagedmov/Nix/nixpkgs/pkgs'
target_maintainer = 'pagedMov'
packages = []
pname_pattern = re.compile(r'pname\s*=\s*"([^"]+)"')
version_pattern = re.compile(r'version\s*=\s*"([^"]+)"')
maintainer_pattern = re.compile(r'maintainers\s*=\s*with\s*lib\.maintainers;\s*\[([^\]]+)\]')
repo_pattern = re.compile(r'homepage\s*=\s*"([^"]+)"')
for dirpath, _, filenames in os.walk(root_dir):
    for filename in filenames:
        file_path = os.path.join(dirpath, filename)
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
                pname_match = pname_pattern.search(content)
                version_match = version_pattern.search(content)
                maintainer_match = maintainer_pattern.search(content)
                repo_match = repo_pattern.search(content)
                if pname_match and version_match and maintainer_match and repo_match:
                    maintainers = maintainer_match.group(1).split()
                    if target_maintainer in maintainers:
                        package_info = {'pname': pname_match.group(1), 'version': version_match.group(1), 'repo': repo_match.group(1)}
                        packages.append(package_info)
        except (UnicodeDecodeError, IOError):
            pass
print(json.dumps(packages, indent=2))
github_api_template = "https://api.github.com/repos/{owner}/{repo}/releases/latest"
updates = []
for package in packages:
    repo_url = package["repo"]
    current_version = package["version"]
    if "github.com" in repo_url:
        owner_repo = repo_url.split("github.com/")[1]
        if owner_repo.endswith("/"):
            owner_repo = owner_repo[:-1]
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
    update_string = '''
    for update in updates:
        update_string += f"  {update['pkg']} -> {update['version']}\n"
    subprocess.run(["notify-send", "--icon=/home/pagedmov/.sysflake/assets/images/nixos-icon-generic.png", "Maintenance Update", f"Updates found:\n{update_string}"])
    subprocess.run(["aplay", "-q", "-N", "/home/pagedmov/.sysflake/assets/sound/login.wav"])
EOF
    '';
    buildInputs = with pkgs; [ python3Packages.requests ];
    installPhase = ":";
  };
in {
  systemd.user = {
    timers = {
      maintenanceCheck = {
        Unit = { Description = "Timer for package maintenance check"; };
        Timer = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
    };
    services = {
      loginSound = {
        Unit= {
          description = "Plays a sound on login";
          After = [ "graphical-session.target" ];
          WantedBy = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.alsa-utils}/bin/aplay -qN ${self}/assets/sound/login.wav";
          Type = "simple";
        };
      };
      maintenanceCheck = {
        Unit = {
          description = "Check for updates in my maintained packages";
        };

        Service = {
          ExecStart = "${pkgs.nix}/bin/nix-shell -p python3Packages.requests --run '${pkgs.python311}/bin/python ${check_updates}/bin/checkupdates.py'";
          Type = "simple";
        };
      };
    };
  };
}
