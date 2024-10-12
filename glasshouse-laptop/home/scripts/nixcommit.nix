{ self, pkgs }:

{
	nixcommit = pkgs.writeShellScriptBin "nixcommit" (''
#!/run/current-system/sw/bin/bash

scheck && runbg aplay ${self}/media/sound/nixswitch-start.wav
builtin cd "$HOME/sysflakes" || exit
nix flake update
if [ -n "$2" ]; then
	echo "too many arguments"
	exit
fi

gen=$(readlink /nix/var/nix/profiles/system | sed 's/.*system-\([0-9]*\)-link/\1/')
gen=$((gen + 1))

diffcheck=$(git status | grep "working tree clean")
if [ -n "$diffcheck" ]; then
	scheck && runbg aplay ${self}/media/sound/warning.wav
	echo "Nothing to commit"
	exit
fi
git add .
git commit -m "Gen $gen: $1"
git push
scheck && runbg aplay ${self}/media/sound/gitpush.wav
builtin cd - || exit
	'');
}
