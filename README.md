# kickassarchinstall
Scripts and configs for an Arch Linux install

These scripts and configs set up Arch Linux with the BTRFS filesystem. It uses an OpenSUSE style layout so that you can use the snapper rollback featute better.
You can boot into a read-only snapshots using the grub menu then run `snapper rollback $num` and reboot. You will then boot into (a R/W copy of) that snapshot.

# Installation
* Boot an Arch Install ISO and get an internet connection. It should be auto-setup if using Ethernet. For WiFi, check out `man iwctl`
* Run these commands
  * `pacman -Sy`
  * `pacman -S git`
  * `git clone https://github.com/tttffff/kickassarchinstall`
  * `cd kickassarchinstall`
  * `bash pre_install.sh`

Follow the instructions and pick your account settings etc. Reboot into your new arch install.

Now you are in your new system run `sudo -i` (or `su -` if you didn't give your account sudo rights)
Change to the root home folder `cd /root` and run `bash post_install.sh`

Sorted =D
  
