#!/bin/bash
if [[ -z "$NULL" ]]; then #o.5th=>1st stage, The Whole mkiso.sh Script, 136 Lines Total, ~5.9 KiB
if [[ -z "$NULL" ]]; then #0.5th stage, Functions & Variables, (Used Functions: A&B, Used Variables: A=>M), 108 Lines (L3=>L111)
A=""
B="/"
C=$(find . -maxdepth 1 -type f -name "*.iso" | head -n 1)
D=$(basename "$C")
E=$(pwd)
F=""$A"/dev/shm/sfs0/"
G=""$A"/run/iso0/"
H=""$A"/dev/shm/iso1/"
I=""$H"/minimalistui/"
J=""$I"/minui/"
K=""$H"/arch/x86_64/airootfs.sfs"

A() { #A Function To Check If TMPFS is Usable/Not
local Z="$1"
Z=${Z:-/dev/shm}
local Y="$2"
local X=$(df -BG --output=avail "$A" | tail -n 1 | sed 's/G//')
if [[ "$X" -ge "3.8" ]]; then
    return 0
    if [[ ! -z "$Y" ]]; then
        local W=$(findmnt -n -o FSTYPE -T "$Y")
        case "$W" in
        ext*|btrfs|xfs|zfs|f2fs)local V="";;
        vfat|exfat|ntfs|fuse|fuseblk)local V="1";;
        *)local V="1";;
        esac
        if [[ -z "$V" ]]; then
            B() { #B Function To Set rsync Command Based On FS Support
            local A=$1
            local B=$2
            rsync -aH "$A" "$B" > /dev/null 2>&1
            }
        else
            B() { #B Function To Set rsync Command Based On FS Support (Alt. Method)
            local A=$1
            local B=$2
            rsync rsync -rv --no-owner --no-group --no-perms --no-times --no-xattrs "$A" "$B" > /dev/null 2>&1
            }
        fi
        export -f B
    fi
elif [[ ! "$A" == "$B" ]]; then
    exec sudo "$0" "$@" && echo "> !!! ERROR: RAM Space is not enough, Checking '"$B"'" && A "$B"
elif [[ "$A" == "$B" ]]; then
    echo "!!! ERROR: RAM/Disk space is not enough. Exiting."
fi
}
C() {
SECONDS="0"
local A=$1
mount "$E"/"$D" "$G" > /dev/null 2>&1
B "$G" "$H"
rm -rf "$G"
umount -l "$G" > /dev/null 2>&1
cd "$H"
unsquashfs -f -n -d "$F" "$K" > /dev/null 2>&1
rm -rf "$I"
mkdir -p "$I"
git clone https://github.com/xv7ranker/minimalistui "$I" > /dev/null 2>&1
rm -rf ""$I"/.git"
rm -rf ""$I"/README.md"
rm -rf ""$I"/LICENSE"
rm -rf ""$I"/devlog.txt"
chmod +x ""$J"/x.sh"
chmod +x ""$J"/c.sh"
chmod +x "$J"/mkisosfs.sh
chmod +x "$J"/mkiso.sh
chmod +x ""$I"/minimalistui.sh"
mv ""$I"/minimalistui.sh" ""$H"/usr/bin/minimalistui.sh"
rm -rf "$H"/etc/pacman.conf
echo "
[options]
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5
DownloadUser = alpm
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional
" > "$H"/etc/pacman.conf
if [[ ! -z "$A" ]]; then
    echo "> Adding Support For Offline Install."
    echo "> Script Is Running In The Background, Please Wait."
    mkdir -p "$J"/flatpak/
    cd "$H"/var/cache/pacman/pkg/
    pacman -Syw --noconfirm --disable-sandbox --cachedir "$L"/var/cache/pacman/pkg/ base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs ntfs-3g unzip p7zip unrar gufw ufw squashfs-tools sudo git intel-ucode amd-ucode xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh fzf bat zoxide neovim lf thefuck kate gparted lutris steam mangohud firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman network-manager-applet udisks2 gvfs kitty fastfetch cpufetch htop papirus-icon-theme flatpak mpd materia-gtk-theme mpv bash-completion kvantum labwc swaybg mako waybar fuzzel grim slurp wl-clipboard kanshi playerctl gst-plugin-pipewire > /dev/null 2>&1
    repo-add extrarepos.db.tar.gz *.pkg.tar.zst > /dev/null 2>&1
    cd "$J"/flatpak/
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1
    flatpak remote-modify flathub --collection-id=org.flathub.Stable > /dev/null 2>&1
    flatpak create-usb --allow-partial "$G"/repos/flatpak/ com.rtosta.zapzap org.telegram.desktop > /dev/null 2>&1
elif [[ -z "$A" ]]; then
    echo "> Skipping Support For Offline Install."
    echo "> Script Is Running In The Background, Please Wait."
fi
rm -rf "$K"
cd "$H"
mksquashfs "." "airootfs.sfs" -comp zstd -Xcompression-level 3 -b 1M -no-progress > /dev/null 2>&1
B "airootfs.sfs" "$K"
cd "$H"
xorriso -as mkisofs -D -r -J -l -V "$M" -o "minui-$M.iso" -p "kata" -publisher "xv7ranker" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "." > /dev/null 2>&1
B ""$H"/"minui-$M.iso"" ""$E"/"minui-$M.iso""
rm -rf "$H"
echo "> Total .iso build time: $SECONDS"
echo "> Script finished. Exiting."
exit 0
}
fi
if [[ -z "$NULL" ]]; then # 1st stage, Introduction, Sudo check, Filename, and Offline Support, 22 Lines (L112=>L134)
echo "> Shell Script (.sh) to automate the creation of minimalistui.iso."
echo "> Run this script in the same direcotry as the .iso that will be the base of your new, minimalistui .iso."
echo "> Legend:
> (d) default option,
> (y/n(d)) yes/no with no as default value,
> (y(d)/n) yes/no with yes as default value,
> Naming Format: minui-VERSION.iso"
while true; do
if [[ $EUID -ne 0 ]]; then
    read -r -p "!!! ERROR: Must Run With Sudo. Rerun With Sudo? (y(d)/n): " R
    R=${R:-y}
    [[ $R == [dD]* ]] && A 1
    [[ $R == [yY]* ]] && exec sudo "$0" "$@" || echo "!!! Exiting." && exit 1
else
    break
fi
done
read -r -p "> What Version Num. Would You Like To Give To Your New .iso?: " M
read -r -p "> Do You Want To Add Offline Install Support For This .iso? (y/n(n)): " R
export M && export -f B
[[ ${R:-n} == [yY]* ]] && C 1 || C
fi
fi
