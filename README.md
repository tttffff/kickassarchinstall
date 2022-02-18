# kickassarchinstall
Scripts and configs for an Arch Linux install

These scripts and configs set up Arch Linux with the BTRFS filesystem. It uses an OpenSUSE style layout so that you can use the snapper rollback featute better.
You will be a able to boot into read-only snapshots using the grub menu then run `snapper rollback $num` to create a R/W copy of that snapshot. Rebooting will then put you into that created snapshot.

It leverages the [ArchInstall](https://github.com/archlinux/archinstall/) script to make our lives easyer by passing config files into it. This also allows for interactive install desisions to be made by the user. Other desisions are made for you, but see the Configuration section below for infomation about changing these.

# Installation
Boot an Arch Install ISO and get an internet connection. It should be auto-setup if using Ethernet. For WiFi, check out `man iwctl`

Run these commands
```
pacman -Sy git
git clone https://github.com/tttffff/kickassarchinstall
cd kickassarchinstall
bash pre_install.sh
```

Follow the instructions and pick your account settings etc. Reboot into your new arch install.

Now that you are in your new system run `sudo -i` (or `su -` if you didn't give your account sudo rights). Change to the root home folder `cd /root` and run `bash post_install.sh`

Sorted =D
  
# Configuration

## Installed software

You can either modify `archinstall_config.txt` before running `bash pre_install.sh` or click on `packages` when in the ArchInstall interactive menu. I suggest leaving rsync in there as it is used for the /boot backup on Kernel upgrades.

As for `snapper` `grub-btrfs` and `snap-pac` that are installed in `post_install.sh`, I suggest leaving these as they are needed for the system that we are creating.

If you don't want [LARBS](https://larbs.xyz/) installing, remove the three lines that reference it at the bottom of `post_install.sh` before you run `bash post_install.sh`.

## Disk layout

The disklayout in `archinstall_disk_layout.txt` has been designed to be used with this set up. Modify it before running `bash pre_install.sh` if you must, but note that the set-up may not work if you do. For example, you may want to remove the @/vmimages @/mariadb @/mysql and @/postgres subvolumes if you know that you will never use them.
