#!/bin/bash
git clone https://github.com/archlinux/archinstall && \
cp *txt archinstall && \
cd archinstall && \
python setup.py install && \
python -m archinstall --config archinstall_config.txt --disk_layouts archinstall_disk_layout.txt && \
mount -o subvol=@/.snapshots/0/snapshot /dev/sda2 /mnt && \
sed -i 's:subvolid=[0-9]\+,subvol=/@/.snapshots/0/snapshot::' /mnt/etc/fstab && \
cp ../post_install.sh /mnt && \
umount /mnt
