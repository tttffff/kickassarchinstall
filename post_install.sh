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
snapper -c root create --description "After Snapper Installed" &&
cp /.snapshots/1/info.xml /.snapshots/0/info.xml &&
sed -i 's/<num>1/<num>0/' /.snapshots/0/info.xml &&
sed -i 's/<description>After Snapper Installed/<description>First Root/' /.snapshots/0/info.xml &&
pacman -S grub-btrfs snap-pac &&
snapper --ambit classic rollback 0 &&
systemctl enable --now grub-btrfs.path &&

grub-mkconfig -o /boot/grub/grub.cfg &&
pacman -S ttf-bitstream-vera ttf-croscore ttf-dejavu gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family locate tmux btop vim  && \
sed -i 's/PRUNENAMES = "/PRUNENAMES = ".snapshots /' /etc/updatedb.conf &&
# snapper -c root create --description "Before LARBS" &&
systemctl enable --now snapper-timeline.timer &&
systemctl enable --now snapper-cleanup.timer &&
# curl -LO larbs.xyz/larbs.sh &&
# sh larbs.sh &&
snapper -c root create --description "After Install"
