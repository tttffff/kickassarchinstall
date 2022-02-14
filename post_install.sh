#!/bin/bash
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="video=1920x1080 /' /etc/default/grub &&
sed -i 's/rootflags=subvol=${rootsubvol}//' /etc/grub.d/10_linux &&
# Tell Pacman not to install cron files
pacman -S snapper &&
snapper -c home create-config /home &&
# Change the config for TIMELINE
cp /etc/snapper/configs/home /etc/snapper/configs/root &&
sed -i 's:SUBVOLUME="/home":SUBVOLUME="/":' /etc/snapper/configs/root &&
sed -i 's/SNAPPER_CONFIGS="/SNAPPER_CONFIGS="root /' /etc/conf.d/snapper &&
systemctl restart snapperd &&
snapper -c root create --description "After Snapper Installed" &&
cp /.snapshots/2/info.xml /.snapshots/1/info.xml &&
sed -i 's/<num>2/<num>1/' /.snapshots/1/info.xml &&
sed -i 's/<description>After Snapper Installed/<description>First Root/' /.snapshots/1/info.xml &&
pacman -S grub-btrfs snap-pac &&
btrfs subvolume set-default / &&
systemctl enable --now grub-btrfs.path &&

grub-mkconfig -o /boot/grub/grub.cfg &&
sed -i 's/PRUNENAMES = "/PRUNENAMES = ".snapshots /' /etc/updatedb.conf &&
# snapper -c root create --description "Before LARBS" &&
systemctl enable --now snapper-timeline.timer &&
systemctl enable --now snapper-cleanup.timer &&
# curl -LO larbs.xyz/larbs.sh &&
# sh larbs.sh &&
snapper -c root create --description "After Install"
