{ pkgs }:

pkgs.writeShellScriptBin "mkbackup" ''
if ! findmnt | grep share; then
	echo "Mounting shared filesystem..."
	if ! sshfs pagedmov@192.168.1.200:/home/pagedmov/share $HOME/share; then
		echo "failed to mount shared storage to $HOME/share" >&2
		exit 1
	fi
	echo "Done"
fi

echo "Copying files..."
if printf '%s\0' "$@" | xargs -0 -I {} cp {} -v "$HOME/share"; then
	echo "Done"
else
	echo "Failed to copy files to shared directory."
	exit 1
fi

echo "Moving files to backup folder on serverside..."
if ssh pagedmov@192.168.1.200 "IFS=' ' read -rA files <<< \"$@\"; for file in \''${files[@]}; do echo -n \"\$(whoami)@\$(hostname): \"; mv -v ~/share/\"\$file\" ~/backup; done"; then
	echo "Backup completed."
	umount $HOME/share
else
	echo "Failed to move files on serverside. Unmounting shared filesystem."
	umount $HOME/share
	exit 1
fi
''
