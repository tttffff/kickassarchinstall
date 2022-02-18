#!/bin/bash

# For users who pick this option (further down)
function install_larbs {
  snapper -c root create --description "Before LARBS" &&
  curl -LO larbs.xyz/larbs.sh &&
  sh larbs.sh
}

# Better resolution when booting, and don't set subvolume for / (this way we will boot from the default BTRFS subvolume)
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="video=1920x1080 /' /etc/default/grub &&
sed -i 's/rootflags=subvol=${rootsubvol}//' /etc/grub.d/10_linux &&

# Turn fsck off (we don't want this for btrfs)
sed -i 's/ fsck//' /etc/mkinitcpio.conf &&
mkinitcpio -P &&

# Tell Pacman not to install cron files for snapper (we will use systemd)
sed -E -i 's:#(NoUpgrade.*):\1 etc/cron.daily/snapper etc/cron.hourly/snapper:' /etc/pacman.conf &&
sed -E -i 's:#(NoExtract.*):\1 etc/cron.daily/snapper etc/cron.hourly/snapper:' /etc/pacman.conf &&

# Don't want updatedb to include files from our snapshots
sed -i 's/PRUNENAMES = "/PRUNENAMES = ".snapshots /' /etc/updatedb.conf &&
sed -i 's:PRUNEPATHS = ":PRUNEPATHS = "/.snapshots :' /etc/updatedb.conf &&

# Create snapper configs, a bit of a jig, but it works. Also change TIMELINE options to something reasonable.
pacman --noconfirm -S snapper &&
snapper -c home create-config /home &&
sed -i 's/LY="10/LY="3/' /etc/snapper/configs/home &&
cp /etc/snapper/configs/home /etc/snapper/configs/root &&
sed -i 's:SUBVOLUME="/home":SUBVOLUME="/":' /etc/snapper/configs/root &&
sed -i 's/SNAPPER_CONFIGS="/SNAPPER_CONFIGS="root /' /etc/conf.d/snapper &&
systemctl restart snapperd &&
snapper -c root create --description "After Snapper Installed" &&
cp /.snapshots/2/info.xml /.snapshots/1/info.xml &&
sed -i 's/<num>2/<num>1/' /.snapshots/1/info.xml &&
sed -i 's/<description>After Snapper Installed/<description>First Root/' /.snapshots/1/info.xml &&

echo "Would you like to install LARBS? (https://larbs.xyz)" &&
echo "Personally, I think it's great, but you may not want to do this if you are using a DM like Gnome or KDE" &&
read -p "(Y/N): " confirm && [[ $confirm == [yY] ]] && install_larbs

echo "Would you like to create a new snapshot after every pacman command?" &&
echo "This is great if you want to rollback after a botched install/upgrade, but can result in LOADS of snapshots if you regually install/upgrade things" &&
read -p "(Y/N): " confirm && [[ $confirm == [yY] ]] && pacman --noconfirm -S snap-pac

# So that we get a snapshots added to grub and a snapshot after every pacman command
pacman --noconfirm -S grub-btrfs &&
systemctl enable --now grub-btrfs.path &&
# Re-create grub config
btrfs subvolume set-default / &&
grub-mkconfig -o /boot/grub/grub.cfg &&

systemctl enable --now snapper-timeline.timer &&
systemctl enable --now snapper-cleanup.timer &&

snapper -c root create --description "After Kickassarchinstall"
