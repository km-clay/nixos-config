#!/run/current-system/sw/bin/bash
echo "Welcome. This script will install pagedMov's NixOS configuration flake onto your machine."
echo "If this script stops at any point, it will resume from the most recent major step when you call it again."
echo "Call the script with --reset to restart the installation process"

set -e
trap 'echo "Aborting installation."; exit 1' INT

if [ "$1" = "--reset" ]; then
	rm -rf /tmp/reset
fi

if [ ! -f /tmp/install_steps ]; then
	echo "0" > /tmp/install_steps
fi

install_step=$(cat /tmp/install_steps)

step_1() {
	# set up working directory
	mkdir -p /tmp/install_pwd && cd /tmp/install_pwd
	rm -rf ./*

	# download disko.nix file for defining partitions
	echo -n "Downloading partition plan..."
	curl -s https://raw.githubusercontent.com/pagedMov/pagedmov-nix-cfg/refs/heads/master/hosts/installer/disko-ext4-singledisk.nix > disko.nix
	echo "Done!"

	echo
	echo "This script is about to format and partition a hard drive."
	sleep 2.5
	echo -e "\033[4;31mThis process is irreversible and will destroy all data on the drive.\033[0m"
	sleep 2.5
	echo "Make absolutely sure that you know which drive you are choosing."
	sleep 2.5
	echo
	lsblk -d -o NAME,SIZE
	echo
	echo -n "Which drive do you wish to sacrifice? "
	read -r drive

	size=$(lsblk -b -d -o NAME,SIZE | grep "$drive" | awk '{ printf "%.0f\n", $2 / 1024 / 1024 / 1024 }')
	size=$((size-1))
	root_size_default=$(echo "scale=0;$size * 0.10 / 1" | bc)
	nix_size_default=$(echo "scale=0;$size * 0.35 / 1" | bc)

	echo
	for part in "root" "nix"; do
			echo "You have $size GB remaining to work with on this drive. How big do you want your $part partition?"

			if [ "$part" = "root" ]; then
					echo "Default value is 10% of hard drive space ($root_size_default GB)"
			else
					echo "Default value is 35% of hard drive space ($nix_size_default GB)"
			fi
			echo "Give a positive integer or leave blank to use default value"
			echo
		deciding=true

		while $deciding; do
				echo -n "> "
				read -r size_choice

				case "$size_choice" in
						'')
							deciding=false
							;;
						*[!0-9]*)  # Matches non-numeric input
								echo "Invalid input. Please enter a valid positive number."
								;;
						0)  # Matches zero
								echo "Please enter a positive number greater than zero."
								;;
						*)  # Matches positive numbers
								if (( size_choice > size - 50 )); then
										echo "You need to leave more room for the other partitions."
									elif (( size_choice < 5 )); then
										echo "Partition size is too small."
									else
										echo "Valid input: $size_choice"
										deciding=false  # Exit the loop on valid input
								fi
								;;
				esac
		done

		case "$part" in
			"root" )
				if [ -z "$size_choice" ]; then root_size=$root_size_default; else root_size=$size_choice; fi
				size=$((size - root_size))
				;;
			"nix" )
				if [ -z "$size_choice" ]; then nix_size=$nix_size_default; else nix_size=$size_choice; fi
				size=$((size - nix_size))
				;;
		esac
	done

	echo
	echo "Final partition sizes:"
	echo "root: $root_size GB"
	echo "nix: $nix_size GB"
	echo "home: $size GB"
	echo

	sleep 1

	# commence formatting
	echo "Commencing formatting/partitioning..." && sleep 0.5
	nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/install_pwd/disko.nix --arg device "\"/dev/$drive\"" --arg root_size "\"$root_size\G\"" --arg nix_size "\"$nix_size\G\"" 

	mount /dev/disk/by-partlabel/disk-main-root /mnt
	mkdir -p /mnt/nix && mount /dev/disk/by-partlabel/disk-main-nix /mnt/nix
	mkdir -p /mnt/boot && mount /dev/disk/by-partlabel/disk-main-ESP /mnt/boot
	mkdir -p /mnt/home && mount /dev/disk/by-partlabel/disk-main-home /mnt/home 
}

step_2() {
	mkdir -p /mnt/etc
	cd /mnt/etc/
	if [ ! -d ./nixos ]; then
		git clone https://github.com/pagedMov/nixos-config.git ./nixos

		echo
		echo "Do you want to install the light or heavy configuration?"
		echo "Light configuration does not include gaming or virtualization features; intended for laptops, etc."
		echo "Heavy config includes gaming and virtualization features; intended for performant desktop environments."
		echo
		select config in "Heavy" "Light" "Quit"; do
			case $config in
				"Heavy")
					echo "Installing heavy configuration \`Oganesson\`"
					config="oganesson"
					sleep 0.5
					break
					;;
				"Light")
					echo "Installing light configuration \`Mercury\`"
					config="mercury"
					sleep 0.5
					break
					;;
				"Quit")
					echo "Exiting installation..."
					sleep 0.5
					exit 0
					;;
				*)
					echo "Invalid option."
					sleep 0.5
					;;
			esac
		done
	fi

	nixos-install --root /mnt --flake /mnt/etc/nixos#"$config" --no-root-password

	echo
	echo "Preliminary installation successful!"
	echo "Beginning secondary installation phase..."
	echo
}

step_3() {
cp -r /mnt/etc/nixos /mnt/home/pagedmov/.sysflake
rm -rf /mnt/etc/nixos
ln -s /mnt/home/pagedmov/.sysflake /etc/nixos

nixos-enter <<-HEREDOC
chown -R pagedmov /home/pagedmov/.sysflake
nixos-generate-config --show-hardware-config > /home/pagedmov/.sysflake/hosts/laptop/hardware.nix
NIXOS_SWITCH_USE_DIRTY_ENV=1 nixos-rebuild boot --flake /home/pagedmov/.sysflake#$config
HEREDOC

echo "INSTALLATION COMPLETE ! !" | toilet -f 3d -w 120 | lolcat -a -s 180
echo "You can now reboot into your new system."
echo "The system configuration flake will be found in your home folder under .sysflake"
echo "/etc/nixos is a symlink leading to the .sysflake folder"
}

next_step() {
	((install_step += 1))
	echo $install_step > /tmp/install_steps
}

running=true
while $running; do
	case $install_step in
		0) step_1;next_step;;
		1) step_2;next_step;;
		2) step_3;next_step;;
		3) step_4;next_step;;
	esac
done
