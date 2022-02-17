#!/bin/bash

# Get the latest ArchInstall (it will work with this set up), copy config files, install and run
git clone https://github.com/archlinux/archinstall &&
cp *txt archinstall &&
cd archinstall &&
python setup.py install &&
sleep 2 &&
python -m archinstall --config archinstall_config.txt --disk_layouts archinstall_disk_layout.txt &&

# Change /etc/fstab before booting into new system
mount -o subvol=@/.snapshots/1/snapshot /dev/sda2 /mnt &&
# I don't know why genfstab adds this into fstab, it doesn't seem to do anthing, and we deffo don't want it later
sed -i 's:,subvolid=[0-9]\+,subvol=/@/.snapshots/1/snapshot::' /mnt/etc/fstab &&
# Better options for our BTFS volumes
sed -i 's/rw,relatime,space_cache=v2/defaults,noatime,autodefrag,ssd,discard=async,compress=zstd,space_cache=v2/' /mnt/etc/fstab &&
sed -E -i 's/((images|mariadb|mysql|pgsql)\s+btrfs\s+defaults,)/\1nodatacow,/' /mnt/etc/fstab &&
umount /mnt &&

# Copy post install script to root user
mount -o subvol=@/root /dev/sda2 /mnt &&
cp ../post_install.sh /mnt &&

echo "SMASHED IT. Please reboot and run the post_install script (it is in /root)"
