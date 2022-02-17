#!/bin/bash

clear &&

printf "
Welcome to the kickassarchinstall.

This script ArchLinux with BTRFS in a more OpenSUSE style layout so that snapper rollbacks work.
Other packages will be installed and configurations made. Look in and modify these scripts if needs be.

-------------------------------------------------------------------------------------------------------
" &&

lsblk | grep disk &&
read -p "Enter the drive that you would like to install on (e.g. sda): " drive &&
drive=/dev/$drive &&
echo "This script will completly wipe ${drive}" &&
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
sed -i "s:HARDDRIVE_GOES_HERE:${drive}:" archinstall_disk_layout.txt &&
sed -i "s:HARDDRIVE_GOES_HERE:${drive}:" archinstall_config.txt &&

printf "
-------------------------------------------------------------------------------------------------------
We are about to run ArchInstall with our config. You will be able to pick things like your user accounts, profile etc
I suggest picking profile xorg so we can get the drivers set up ready for LARBS without installing any bloat

Unless you are SURE, select NO to: Would you like to chroot into the newly created installation and perform post-installation configuration?
The scripts will do all the post configuration that you need.

" &&

read -p "Press enter to continue..." &&

# Get the latest ArchInstall (it will work with this set up), copy config files, install and run
git clone https://github.com/archlinux/archinstall &&
cd archinstall &&
python setup.py install &&
# Sometimes it fails first time, can't work it out tbh. Purposefully failing it first time solves that.
python -m archinstall --config NOTAREALFILE &> /dev/null
python -m archinstall --config ../archinstall_config.txt --disk_layouts ../archinstall_disk_layout.txt &&
cd .. &&

# Change /etc/fstab before booting into new system
# I don't know why genfstab adds this into fstab, it doesn't seem to do anthing, and we deffo don't want it later
sed -i 's:,subvolid=[0-9]\+,subvol=/@/.snapshots/1/snapshot::' /mnt/archinstall/etc/fstab &&
# Better options for our BTFS volumes
sed -i 's/rw,relatime,space_cache=v2/defaults,noatime,autodefrag,ssd,discard=async,compress=zstd,space_cache=v2/' /mnt/archinstall/etc/fstab &&
sed -E -i 's/((images|mariadb|mysql|pgsql)\s+btrfs\s+defaults,)/\1nodatacow,/' /mnt/archinstall/etc/fstab &&
# Copy packman hook to backup /boot when there's any majot changes
mkdir /mnt/archinstall/etc/pacman.d/hooks &&
cp 50-bootbackup.hook /mnt/archinstall/etc/pacman.d/hooks/50-bootbackup.hook &&

# Copy post install script to root user
cp post_install.sh /mnt/archinstall/root &&

echo "SMASHED IT. Please reboot and run the post_install script (it is in /root)"
