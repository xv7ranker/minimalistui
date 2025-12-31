#!/bin/bash
A=""
B=""
H="" #L
J=""
M=""
O=""
R=""
S=""
D="/"
E="5"
N="1"
T=$(pwd)
P=$(whoami)
U=$(basename "$T")
Q=$(cat /etc/hostname)
F=$(find . -maxdepth 1 -type f -name "*.iso" | head -n 1)
K=$(basename "$F")
L=""$A"/mnt/sfs0"
X=""$A"/mnt/iso0"
Z=""$A"/mnt/iso1"
C=""$L"/minimalistui/minimalistui.sh"
G=""$L"/minui"
W=""$L"/minimalistui"
S=""$Z"/arch/x86_64/airootfs.sfs"
while true; do
if [[ $EUID -ne 0 ]]; then #1st stage, sudo
    echo "!!! ERROR: Must run with sudo."
    read -r -p "!!! Rerun with sudo? (y/n): " R
    case $R in
    [yY]) exec sudo "$0" "$@" ;;
    "") continue ;;
    *) echo "!!! Exiting."
       exit 1 ;;
    esac
else
    break
fi
done
echo "> Shell Script (.sh) to automate minui.iso creation."
echo "> Run this script in the same directory as arch.iso that wanted to be modified to minui.iso."
umount "$X" > /dev/null 2>&1
rm -rf "$X"
rm -rf "$Z"
rm -rf "$L"
rm -rf "$G"
rm -rf "$W"
mkdir -p "$X"
mkdir -p "$Z"
mkdir -p "$L"
echo "> Needed free space of atleast 5GB in '"$D"'."
is_fs_larger_than_gib() {
    local H="$1"
    local Y="$2"
    local free_size=$(df -BG --output=avail "$H" | tail -n 1 | sed 's/G//')
    if [[ "$free_size" -ge "$Y" ]]; then
        return 0
    else
        return 1
    fi
}
check_fs_supports_unix_features() {
    local H="$1"
    local PA=$(findmnt -n -o FSTYPE -T "$H")
    case "$PA" in
        ext*|btrfs|xfs|zfs|f2fs)
            return 0
            ;;
        vfat|exfat|ntfs|fuse|fuseblk)
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}
while true; do
    if is_fs_larger_than_gib "$D" "$E"; then
        echo "> Free space in '"$D"' is enough, continuing."
        cd "/"
        break
    else
        rm -rf "$X"
        rm -rf "$Z"
        rm -rf "$L"
        A="$T"
        echo "!!! ERROR: Free disk space on $D is <${E}GiB. Will check '"$A"' (current running dir.)."
        D="$A"
        if ! [[ "$D" == "/" ]]; then
            L="$A/mnt/sfs0"
            X="$A/mnt/iso0"
            Z="$A/mnt/iso1"
            mkdir -p "$X"
            mkdir -p "$Z"
            mkdir -p "$L"
            continue
        elif [[ "$D" == "$(pwd)" ]]; then
            echo "!!! ERROR: Free disk space on $D is <${E}GiB. Exiting (because '/' and '$A' is <${E}GiB)."
            exit 1
            break
        fi
    fi
done
while true; do
    read -r -p "> What would you want your bootable .iso version be?: " V #2nd stage, reads
    read -r -p "> What would you want your bootable .iso output file name be? (don't add file extension (.iso)): " Y
    echo "> Script is running in the background, please wait."
    mount "$T"/"$K" "$X" > /dev/null 2>&1
    if check_fs_supports_unix_features "$D"; then
        rsync -aH --progress "$X"/ "$Z" > /dev/null 2>&1
    else
        rsync -rv --no-owner --no-group --no-perms --no-times --no-xattrs --progress "$X"/ "$Z" > /dev/null 2>&1
    fi
    cd "$Z"
    unsquashfs -f -d "$L" "$S"> /dev/null 2>&1
    rm -rf "$G"
    rm -rf "$W"
    mkdir -p "$G"
    mkdir -p "$W"
    git clone https://github.com/xv7ranker/minimalistui-extras "$G" > /dev/null 2>&1
    git clone https://github.com/xv7ranker/minimalistui "$W" > /dev/null 2>&1
    rm -rf ""$W"/.git"
    rm -rf ""$W"/README.md"
    rm -rf ""$W"/LICENSE"
    rm -rf ""$W"/devlog.txt"
    rm -rf ""$G"/.git"
    rm -rf ""$G"/README.md"
    rm -rf ""$G"/LICENSE"
    $M
    chmod +x ""$G"/x.sh"
    chmod +x ""$G"/c.sh"
    chmod +x "$C"
    mv "$C" ""$L"/usr/bin/minimalistui.sh"
    chmod +x "$G"/mkisosfs.sh
    chmod +x "$G"/mkiso.sh
    rm -rf "$W"
    rm -rf "$L"/etc/pacman.conf
cat <<'EOF' > "$L"/etc/pacman.conf
[options]
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5
DownloadUser = alpm
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional
EOF
    read -r -p "> Do you want to incl. Offline support for your .iso? (y(d)/n): " R
    if [[ ${R:-y} == [nN]* ]]; then
    echo "> Skipping offline support"
    echo "> Script is running in the background, please wait."
    else
    echo "> Script is running in the background, please wait."
    mkdir -p "$G"/repos/flatpak/
    cd "$L"/var/cache/pacman/pkg/
    pacman -Syw --noconfirm --disable-sandbox --cachedir "$L"/var/cache/pacman/pkg/ base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs ntfs-3g unzip p7zip unrar gufw ufw squashfs-tools sudo git intel-ucode amd-ucode xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh fzf bat zoxide neovim lf thefuck kate gparted lutris steam mangohud firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman network-manager-applet udisks2 gvfs kitty fastfetch cpufetch htop papirus-icon-theme flatpak mpd materia-gtk-theme mpv bash-completion kvantum labwc swaybg mako waybar fuzzel grim slurp wl-clipboard kanshi playerctl gst-plugin-pipewire > /dev/null 2>&1
    repo-add extrarepos.db.tar.gz *.pkg.tar.zst > /dev/null 2>&1
    cd "$G"/repos/flatpak/
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1
    flatpak remote-modify flathub --collection-id=org.flathub.Stable > /dev/null 2>&1
    flatpak create-usb --allow-partial "$G"/repos/flatpak/ com.rtosta.zapzap org.telegram.desktop > /dev/null 2>&1
    cd "$L"
    fi
    rm -rf "$S"
    cd "$L"
    mksquashfs "." "airootfs.sfs" -comp zstd -Xcompression-level 3 -b 1M -no-progress > /dev/null 2>&1
    cp "airootfs.sfs" "$S"
    sync
    cd "$Z"
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${Y}.iso" -p "kata" -publisher "xv7ranker" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "." > /dev/null 2>&1
    cp "$Z"/"${Y}.iso" "$T"/"${Y}.iso" && sync -f "$T"/"${Y}.iso"
    umount -l "$X" > /dev/null 2>&1
    rm -rf "$X"
    rm -rf "$Z"
    rm -rf "$L"
    echo "> Script finished. Exiting."
    exit 0
    break 1
    done
