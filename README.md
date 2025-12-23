# MinimalistUI
based on Arch, inspired by EndeavourOS and archinstall command. A small Arch automatic install script project that installs and targets minimalist, simple, and light Dark-themed UI. This project is still WIP (tho predict 95% useable).

How to install MinimalistUI (using .iso from https://github.com/xv7ranker/minimalistui/releases/new):

1.) use:
sudo dd if=/path/to/minimalistui.iso of=/dev/sdX bs=4M status=progress (for sata devices, change X to coresponding device letter (use lsblk to easily identify)

or

sudo dd if=/path/to/minimalistui.iso of=/dev/nvmeXn1 bs=4M status=progress (for nvme devices, change X to corresponding device number (use lsblk to easily identify)

OR

sudo dd if=/path/to/minimalistui.iso of=/dev/mmcblkX bs=4M status=progress (for MicroSD devices, change X to corresponding device number (use lsblk to easily identify)

To paste .iso into your install media (if you are currently using Linux),

OR

Use rufus and choose your installation media and the minimalistui.iso, then click start (if you are currently using Windows (see https://www.youtube.com/watch?v=RRWRUZbZQeY for more)).

2.) After that, turn off your device, and get into BIOS/UEFI, the key combination to enter BIOS/UEFI is different for each motherboard/laptop brands (you can see https://www.tomshardware.com/reviews/bios-keys-to-access-your-firmware,5732.html for more (the most common key are F2, Delete, F10, and F1)).

3.) Change the BIOS/UEFI boot priority / boot order to your new installation media (see https://www.lifewire.com/change-the-boot-order-in-bios-2624528 for more (BIOS/UEFI settings for each motherboard/laptop brand may vary)), then exit from bios.

4.) after booting up into the Arch Installation TTY, execute command:

chmod +x minimalistui.sh

sh minimalistui.sh

Enter options based on the questions and based on how would you like your MinimalistUI installation be, and continue until minimalistui.sh finished executing.

5.) enter '1' to exit on the very last question to exit the installation, type "reboot" to reboot, Do Not Forget To Unplug Your Installation Media At This Stage.

6.) MinimalistUI is installed into your device! (MinimalistUI didnt have any GUI greeters, so you would need to enter your user name and its password in the TTY to enter (will try to search for alternative)).

possible installable packages:

(pacstrap (important base packages): base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva mesa-vdpau libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs fzf bat zoxide lf thefuck ntfs-3g unzip p7zip unrar gufw ufw neovim squashfs-tools intel-ucode amd-ucode xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon)

(pacman: xfce4 volctl pasystray thunar flatpak kvantum mpv tint2 papirus-icon-theme xfce4-battery-plugin xfce4-notifyd xfce4-pulseaudio-plugin fastfetch cpufetch htop pipewire-alsa pipewire-pulse pipewire-jack pipewire bash-completion mpd kitty ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji materia-gtk-theme firefox udisks2 gvfs network-manager-applet pavucontrol firefox-i18n-en-us git thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman )

(extra installables: (pacman: kate gparted xarchiver xfce4-screenshooter xfce4-mount-plugin xfce4-mpc-plugin xfce4-clipman-plugin lutris steam mangohud xfce4-whiskermenu-plugin firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso) (flatpak: sober zoom zapzap telegram))

Device:
Dell Latitude 7290
Intel Core I5-8350U
Intel Graphics UHD 620
8GB LPDDR4 2600MT/s x1 | 256GB NVMe M.2 SSD | PCIe Gen 3.0 x4
Dual-Boot: MinimalistUI V251223 - Windows 11

Building tools:
- mkiso.sh (to automate minimalistui.iso creations (modifyable if you want to)): https://github.com/xv7ranker/minimalistui-extras/blob/main/mkiso.sh
- mkisosfs.sh (to automate common .iso and .sfs file creation): https://github.com/xv7ranker/minimalistui-extras/blob/main/mkisosfs.sh
- 'xorriso', 'cdrtools', 'squashfs-tools', and 'git' as dependencies.

Legend (For release tags):
- 'W' for WIP (Work In Progress (Useable, but highly experimental and may contain bugs or errors that should be covered by newer releases))
- 'Ot' for Outdated (Useable, but highly not recomended to use, since these versions are very likely to contain bugs or errors that should be fixed in newer releases)
- 'Ol' for Older (useable, but likely using older archlinux .iso base versions or have earlier version of essential minimalistui .sh scripts)

credit to:
- Arch Linux,
- EndeavourOS-team,
- Linus Torvalds,
- Toms Hardware (For BIOS/UEFI key combo page (https://www.tomshardware.com/reviews/bios-keys-to-access-your-firmware,5732.html)),
- Lifewire (For boot priority/boot order modification (https://www.lifewire.com/change-the-boot-order-in-bios-2624528)),
- GEEKrar (For youtube rufus tutorial (https://www.youtube.com/@Geekrar), and
- All of the package providers.
