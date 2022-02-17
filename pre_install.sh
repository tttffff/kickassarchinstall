#!/bin/bash

clear &&

printf "
Welcome to the kickassarchinstall.

We will set ArchLinux with BTRFS in a more OpenSUSE style layout so that snapper rollbacks work.
Other packages will be installed and configurations made. Look in and modify these scripts if needs be.

" &&

lsblk | grep disk &&
read -p "Enter the drive that you would like to install on (e.g. sda): " drive &&
drive=/dev/$drive &&
echo "This script will completly wipe ${drive}" &&
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
sed -i "s:HARDDRIVE_GOES_HERE:${drive}:" archinstall_disk_layout.txt &&
sed -i "s:HARDDRIVE_GOES_HERE:${drive}:" archinstall_config.txt &&

echo "About to run ArchInstall with our config. You will be able to pick things like your user accounts, profile etc" &&
echo "I suggest picking profile xorg so we can get the drivers set up ready for LARBS without installing any bloat" &&
read -p "Press enter to continue..." &&

# Get the latest ArchInstall (it will work with this set up), copy config files, install and run
git clone https://github.com/archlinux/archinstall &&
cp *txt archinstall &&
cd archinstall &&
python setup.py install &&
# Sometimes it fails first time, can't work it out tbh.
python -m archinstall --config archinstall_config.txt --disk_layouts archinstall_disk_layout.txt ||
(pwd && python -m archinstall --config archinstall_config.txt --disk_layouts archinstall_disk_layout.txt) &&
cd .. &&

# Change /etc/fstab before booting into new system
mount -o subvol=@/.snapshots/1/snapshot /dev/sda2 /mnt &&
# I don't know why genfstab adds this into fstab, it doesn't seem to do anthing, and we deffo don't want it later
sed -i 's:,subvolid=[0-9]\+,subvol=/@/.snapshots/1/snapshot::' /mnt/etc/fstab &&
# Better options for our BTFS volumes
sed -i 's/rw,relatime,space_cache=v2/defaults,noatime,autodefrag,ssd,discard=async,compress=zstd,space_cache=v2/' /mnt/etc/fstab &&
sed -E -i 's/((images|mariadb|mysql|pgsql)\s+btrfs\s+defaults,)/\1nodatacow,/' /mnt/etc/fstab &&
# Copy packman hook to backup /boot when there's any majot changes
cp 50-bootbackup.hook /mnt/etc/pacman.d/hooks/50-bootbackup.hook &&
umount /mnt &&

# Copy post install script to root user
mount -o subvol=@/root /dev/sda2 /mnt &&
cp ../post_install.sh /mnt &&

echo "SMASHED IT. Please reboot and run the post_install script (it is in /root)"
