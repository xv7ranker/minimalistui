#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    read -r -p "!!! ERROR: Must run with sudo. Rerun with sudo? (y(d)/n): " R
    R=${R:-y}
    [[ $R == [yY]* ]] && exec sudo "$0" "$@" || echo "!!! Exiting." && exit 1
fi
mkdir -p /minui/
mkdir -p /minui/backgrounds/
mkdir -p /minui/bin/
mkdir -p /minui/config/
mkdir -p /usr/local/bin/minui/
sh -c 'cat << "EOF" > /usr/minui/bin/cpu-maxperf
#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    read -r -p "!!! ERROR: Must run with sudo. Rerun with sudo? (y(d)/n): " R
    R=${R:-y}
    [[ $R == [yY]* ]] && exec sudo "$0" "$@" || echo "!!! Exiting." && exit 1
fi
for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
echo "performance" > $CPU
done
echo "10" > /proc/sys/vm/swappiness > /dev/null 2>&1
EOF'
chmod +x /usr/minui/bin/cpu-perf > /dev/null 2>&1
sh -c 'cat << "EOF" > /usr/minui/bin/cpu-powersave
#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    read -r -p "!!! ERROR: Must run with sudo. Rerun with sudo? (y(d)/n): " R
    R=${R:-y}
    [[ $R == [yY]* ]] && exec sudo "$0" "$@" || echo "!!! Exiting." && exit 1
fi
for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
echo "powersave" > $CPU
done
echo "10" > /proc/sys/vm/swappiness > /dev/null 2>&1
EOF'
chmod +x /usr/minui/bin/cpu-pwrsv > /dev/null 2>&1
sh -c 'cat << "EOF" > /usr/minui/bin/brght
#!/bin/bash
# Usage: brightness [1-100]
A=1
B=100
C=$1
if [[ $EUID -ne 0 ]]; then
    read -r -p "!!! ERROR: Must run with sudo. Rerun with sudo? (y(d)/n): " R
    R=${R:-y}
    [[ $R == [yY]* ]] && exec sudo "$0" "$@" || echo "!!! Exiting." && exit 1
fi
if [ -z "$C" ]; then
    echo "Usage: sudo brightness [1-$B]"
    exit 1
fi
# Input validation
if ! [[ $C =~ ^[0-9]+$ ]] || [ "$C" -lt "A" ] || [ "$C" -gt "$B" ]; then
    echo "Error: Brightness must be between $A and $B."
    exit 1
fi
# --- FUNCTION: KERNEL (SYSFS) BRIGHTNESS CALCULATION ---
set_sysfs_brightness() {
local DIR="$1"
if [ ! -d "$DIR" ] || [ ! -f "$DIR/max_brightness" ] || [ ! -f "$DIR/brightness" ]; then
    return 1
fi
D=$(cat "$DIR/max_brightness")
E=$((C * D / 100))
if [ "E" -lt 1 ]; then
    E=1
fi
echo "$E" | tee "$DIR/brightness" > /dev/null
# REPORTING TIER 1
echo "Brightness set to $C% (Method: /sys/class/backlight/)."
return 0
}
# 1. PRIMARY TIER: Consolidated Kernel/Sysfs Check
for DIR in /sys/class/backlight/*; do
if set_sysfs_brightness "$DIR"; then
    exit 0
fi
done
# 2. SECONDARY FALLBACK: The light Utility
if command -v light &> /dev/null; then
    sudo -u $SUDO_USER     DISPLAY=$DISPLAY     XAUTHORITY=$XAUTHORITY     light -S "$C" 2>/dev/null
    if [ $? -eq 0 ]; then
        # REPORTING TIER 2
        echo "Brightness set to $C% (Method: light)."
        exit 0
    fi
fi
# FINAL ERROR MESSAGE
echo "Error: Failed to set brightness."
echo "Install light or check path."
exit 1
EOF'
chmod +x /usr/minui/bin/brght > /dev/null 2>&1
sh -c 'cat << "EOF" > /usr/minui/bin/vol
#!/bin/bash
# Usage: volume [0-150] | volume mute
A=$1
B=150
C=$2
if [ -z "$A" ]; then
    echo "Usage: vol [0-$B] or vol t"
    exit 1
fi
if command -v pactl &> /dev/null; then
    ${A//%/} && A=${A}%
    # --- MUTE OPTION ---
    if [[ "$A" == [tT] && -z "$C" ]]; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            D=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q)
            if [ "$D" == "yes" ]; then
                echo "Volume set to muted."
            else
                echo "Volume set to unmuted."
            fi
            exit 0
        fi
    elif [ "$A" == [tT] && ! -z "$C" ]; then
        amixer sset Master toggle > /dev/null 2>&1
        if [ $? -eq 0]; then
            D=$(amixer get Master | grep -q "\[off\]")
            if [ "D" -eq 1]; then
                echo "Volume set to muted."
            else
                echo "Volume set to unmuted."
            fi
            exit 0
    fi
    # --- PERCENTAGE OPTION ---
    if ! [[ $A =~ ^[0-9]+$ ]] || [ "$A" -lt 0 ] || [ "$A" -gt "$B" ]; then
        echo "Error: Volume percentage must be between 0 and $B."
        exit 1
    fi
    # Set volume
    if [[ -z "$C" ]]; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$A" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Volume set to $A."
            exit 0
        else
            echo "Error: Failed to adjust volume."
            exit 1
        fi
    elif [[ ! -z "$C" ]]; then
        amixer sset Master "$A" > /dev/null 2>&1
    fi
else
    if [[ -z "$C" ]]; then
        echo "!!! ERROR: wpctl not found. Using fallback method."
        exec "$0" "$@" 1
    elif [[ ! -z "$C" ]]; then
        echo "!!! ERROR: amixer not found."
    fi
fi
EOF'
chmod +x /usr/minui/bin/vol > /dev/null 2>&1
sh -c 'cat << "EOF" > /usr/minui/bin/mpvw
#!/bin/bash
A=$(find /home -maxdepth 1 -mindepth 1 -type d -not -name "lost+found" -printf "%f\n" | shuf -n 1)
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    B="drm"
else
    B="gpu"
if [ -z $1 ]; then
    echo "> Usage: mpvw <video_file> [vlc_options]"
    echo "> This Command Is Only Available In CLI Environment."
    echo "> Run "mpvw h" for available options."
    echo "> Run "mpvw w" to choose which file to watch."
    exit 1
fi
if [ "$1" == 1* ]; then
    while read -r file; do
    file["$file"]="$file"
    done < <(find . -type f \( -iname "*.jpg" -or -iname "*.png" -or -iname "*.mkv" \))
    count=${#file[@]}
    if [[ "$count" -gt 1 ]]; then
        echo "> Which File Do You Want To Watch? "
        select choice in "${!file[@]}"; do
        if [[ -z $choice ]]; then
            read -r -p "> Do You Want To Exit? (y(d)/n): " R
            [[ ${R:-y} == [yY]* ]] && break || continue
        fi
        if [[ -n $choice && $choice ]]; then
            FILE=${file[$choice]}
            break
            else
            continue
        fi
        done
        elif [[ "$count" -eq 1 ]]; then
        FILE="${!file[@]}"
    fi
    mpv --vo=$B "$FILE"
fi
if [ $1 == [hH] ]; then
    mpv --help
fi
if [[ $EUID -eq 0 ]]; then
    sudo -u $A mpv --vo=$B "$@"
    exit 0
fi
mpv --vo=$B "$@"
exit 0
EOF'
chmod +x /usr/minui/bin/mpvw > /dev/null 2>&1
echo "To See Commands That Are Available In CLI Environtment, use command 'ls /usr/minui/bin'"
sh -c 'cat <<"EOF" > /usr/bin/startminuix
#!/bin/bash
#
#  MinimalistUI
#
#  MIT License
#
#  Copyright (c) 2025 xv7ranker
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
exec startx "$0"
exit
fi
feh --bg-fill --image-bg "#000000" & dunst & tint2 -c /minui/config/tint2rc &
exec openbox
EOF'
chmod +x /usr/bin/startminuix > /dev/null 2>&1
sh -c 'cat <<"EOF" > /usr/bin/startminuiw
#!/bin/bash
#
#  MinimalistUI
#
#  MIT License
#
#  Copyright (c) 2025 xv7ranker
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
exec labwc
exit
fi
EOF'
chmod +x /usr/bin/startminuiw > /dev/null 2>&1
A=$(date +"%Y.%m.%d") && sed -i "s/BUILD_ID=.*/BUILD_ID=\"$A\"/" "$0"
sh -c 'cat <<"EOF" > /usr/lib/os-release
NAME="MinimalistUI"
PRETTY_NAME="MinimalistUI"
ID="arch"
ID_LIKE="arch"
BUILD_ID="2025.12.23"
ANSI_COLOR="0;0;0;0;0"
HOME_URL="https://github.com/opranker/minimalistui"
DOCUMENTATION_URL="https://github.com/opranker/minimalistui/discussions"
SUPPORT_URL="https://github.com/opranker/minimalistui/discussions"
BUG_REPORT_URL="https://github.com/opranker/minimalistui/discussions"
LOGO="arch"
EOF'
chmod +x /usr/lib/os-release > /dev/null 2>&1
ln -sf /usr/lib/os-release /minui/os-release
sh -c 'cat <<"EOF" > /minui/bin/mkiso
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
L=""$H"/do"

A() { #A Function To Check If TMPFS is Usable/Not
local Z="$1"
Z=${Z:-/dev/shm}
local Y="$2"
local X=$(df -BG --output=avail "$Z" | tail -n 1 | sed "s/G//")
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
    exec sudo "$0" "$@" && echo "> !!! ERROR: RAM Space is not enough, Checking "$B"" && A "$B"
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
git clone https://github.com/xv7ranker/do "$L" > /dev/null 2>&1
rm -rf ""$I"/.git"
rm -rf ""$I"/README.md"
rm -rf ""$I"/LICENSE"
rm -rf ""$I"/devlog.txt"
rm -rf ""$L"/.git"
rm -rf ""$L"/README.md"
rm -rf ""$L"/LICENSE"
chmod +x ""$I"/minimalistui.sh"
chmod +x ""$I"/x.sh"
chmod +x ""$L"/do.sh"
mv ""$I"/minimalistui.sh" ""$H"/etc/profile.d/minimalistui.sh"
mv ""$I"/x.sh" ""$F"/x.sh"
mv ""$I"/do.sh" ""$F"/do.sh"
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
    cd "$F"/var/cache/pacman/pkg/
    pacman -Syw --noconfirm --disable-sandbox --cachedir "$F"/var/cache/pacman/pkg/ base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs ntfs-3g unzip p7zip unrar gufw ufw squashfs-tools sudo git intel-ucode amd-ucode xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh fzf bat zoxide neovim lf thefuck kate gparted lutris steam mangohud firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman network-manager-applet udisks2 gvfs kitty fastfetch cpufetch htop papirus-icon-theme flatpak mpd materia-gtk-theme mpv bash-completion kvantum labwc swaybg mako waybar fuzzel grim slurp wl-clipboard kanshi playerctl gst-plugin-pipewire > /dev/null 2>&1
    repo-add extrarepos.db.tar.gz *.pkg.tar.zst > /dev/null 2>&1
    cd "$J"/flatpak/
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1
    flatpak remote-modify flathub --collection-id=org.flathub.Stable > /dev/null 2>&1
    flatpak create-usb --allow-partial "$J"/flatpak/ com.rtosta.zapzap org.telegram.desktop > /dev/null 2>&1
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
EOF'
chmod +x /minui/bin/mkiso > /dev/null 2>&1
sh -c 'cat <<"EOF" > /minui/bin/mkisosfs
#!/bin/bash
echo "Shell Script (.sh) to automate .iso and .sfs creation" # echo "Make sure to run the command in the same directory as the contents of the .iso or the .sfs"
while true; do
read -r -p "What would you like to create?
- 1 to create .iso,
- 2 to create .iso and .sfs,
- 3 to create .sfs,
- 0 to exit.
- answer: " W
case $W in
1)  read -r -p "What would you want your bootable .iso version be? (have not much effect): " V
    read -r -p "What would you want your bootable .iso output file name be? (have not much effect) (do not add the file extension (.iso), its already added inside the script)): " I
    read -r -p "What would you want your bootable .iso preparer name be? (have not much effect): " R
    read -r -p "What would you want your bootable .iso publisher name be? (have not much effect): " B
    read -r -p "Where is the directory to your .iso file contents? (leave empty if you are in the same directory as the contents, include the directory if the .iso file contents are not in the same directory as you are currently running the command in.): " S
    case $S in
    "") S="." ;;
    *) S="$S";;
    esac
    echo "creating .iso"
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${I}.iso" -p "$R" -publisher "$B" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "$S"
    echo ".iso creation finished"
    while true; do
    read -r -p "Would you like to exit {0} or would you like to continue {1}?: " CO
    case $CO in
    0) exit 0 ;;
    1) break 2 ;;
    *) continue ;;
    esac
    done ;;
2)  read -r -p "What would you want your bootable .iso version be? (have not much effect): " V
    read -r -p "What would you want your bootable .iso and .sfs output file name be? (have not much effect) (do not add the file extension (.iso and or .sfs), its already added inside the script)): " I
    read -r -p "What would you want your bootable .iso preparer name be? (have not much effect): " R
    read -r -p "What would you want your bootable .iso publisher name be? (have not much effect): " B
    EX=""
    while true; do
    read -r -p "Where is the directory to your .iso and .sfs file contents? (leave empty if you are in the same directory as the contents, include the directory if the .iso and .sfs file contents are not in the same directory as you are currently running the command in.): " S
    case $S in
    "") S="." ;;
    *) S="$S";;
    esac
    read -r -p "What compression algorithm would you like to use?
    - 1 gzip (less compression, faster),
    - 2 xz (better compression, slower),
    - 0 none.
    - answer: " C
    case $C in
    1) C="-comp gzip" ;;
    2) C="-comp xz" ;;
    0) C="" ;;
    "") continue ;;
    esac
    read -r -p "What directory would you like to exclude from the .sfs file? (enter nothing to skip)" E
    case $E in
    "") ;;
    *) EX="-e \"$E\"" ;;
    esac
    echo "creating .iso"
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${I}.iso" -p "$R" -publisher "$B" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "$S"
    echo ".iso creation finished"
    echo "creating .sfs"
    mksquashfs "$S" "${I}.sfs" $C $EX -b 1M -no-progress
    echo ".sfs creation finished"
    read -r -p "Would you like to exit {0} or would you like to continue {1}?: " CO
    case $CO in
    0) exit 0 ;;
    1) break 2 ;;
    *) continue ;;
    esac
    done ;;
3)  read -r -p "What would you want your .sfs output file name be? (have not much effect (do not add the file extension (.sfs), its already added inside the script)): " I
    EX=""
    while true; do
    read -r -p "Where is the directory to your .sfs file contents? (leave empty if you are in the same directory as the contents, include the directory if the .sfs file contents are not in the same directory as you are currently running the command in.): " S
    case $S in
    "") S="." ;;
    *) S="$S";;
    esac
    read -r -p "What compression algorithm would you like to use?
    - 1 gzip (less compression, faster),
    - 2 xz (better compression, slower),
    - 0 none.
     - answer: " C
    case $C in
    1) C="-comp gzip" ;;
    2) C="-comp xz" ;;
    0) C="" ;;
    "") continue ;;
    esac
    read -r -p "What directory would you like to exclude from the .sfs file? (enter nothing to skip)" E
    case $E in
    "") ;;
    *) EX="-e \"$E\"" ;;
    esac
    echo "creating .sfs"
    mksquashfs "$S" "${I}.sfs" $C $EX -b 1M -no-progress
    echo ".sfs creation finished"
    read -r -p "Would you like to exit {0} or would you like to continue {1}?: " O
    case $O in
    0) exit 0 ;;
    1) break 2 ;;
    *) continue ;;
    esac
    done ;;
0) echo "Exiting."
    exit 0 ;;
"") continue ;;
esac
done
EOF'
chmod +x /minui/bin/mkisosfs > /dev/null 2>&1
sh -c 'cat <<"EOF" > /minui/config/tint2.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Tint2
Exec=tint2
StartupNotify=false
Terminal=false
Hidden=false
EOF'
chmod +x /minui/config/tint2.desktop > /dev/null 2>&1
sh -c 'cat <<"EOF" > /minui/config/labwc
#!/bin/sh
#
#  MinimalistUI Labwc Autostart
#  Location: ~/.config/labwc/autostart
#
swaybg -i /usr/minui/backgrounds/wp.png -m fill &
waybar &
mako &
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
EOF'
chmod +x /minui/config/labwc > /dev/null 2>&1
cat <<'EOF' > /minui/config/mpv.conf
hwdec=vaapi
cache=yes
demuxer-max-bytes=150MiB
demuxer-readahead-sec=60
vo=gpu
cscale=bilinear
tscale=linear
interpolation=no
vd-lavc-threads=auto
ao=pipewire
EOF
source /v.sh
sh -c 'cat <<"EOF" > /minui/config/tint2rc
#---- Generated by tint2conf b2ff ----
# See https://gitlab.com/o9000/tint2/wikis/Configure for
# full documentation of the configuration options.
#-------------------------------------
# Gradients
#-------------------------------------
# Backgrounds
# Background 1:
rounded = 0
border_width = 0
border_sides = TBLR
border_content_tint_weight = 0
background_content_tint_weight = 0
background_color = #000000 60
border_color = #000000 30
background_color_hover = #000000 60
border_color_hover = #000000 30
background_color_pressed = #000000 60
border_color_pressed = #000000 30

# Background 2:
rounded = 4
border_width = 1
border_sides = TBLR
border_content_tint_weight = 0
background_content_tint_weight = 0
background_color = #777777 20
border_color = #777777 30
background_color_hover = #aaaaaa 22
border_color_hover = #eaeaea 44
background_color_pressed = #555555 4
border_color_pressed = #eaeaea 44

# Background 3: Active desktop name, Active task, Active taskbar, Battery, Button, Clock, Default task, Iconified task, Inactive desktop name, Inactive taskbar, Launcher, Launcher icon, Normal task, Panel, Separator, Urgent task
rounded = 4
border_width = 1
border_sides = TBLR
border_content_tint_weight = 0
background_content_tint_weight = 0
background_color = #bf3f3f 0
border_color = #bf3f3f 0
background_color_hover = #bf3f3f 0
border_color_hover = #bf3f3f 0
background_color_pressed = #bf3f3f 0
border_color_pressed = #bf3f3f 0

# Background 4:
rounded = 4
border_width = 1
border_sides = TBLR
border_content_tint_weight = 0
background_content_tint_weight = 0
background_color = #aa4400 100
border_color = #aa7733 100
background_color_hover = #cc7700 100
border_color_hover = #aa7733 100
background_color_pressed = #555555 4
border_color_pressed = #aa7733 100

# Background 5: Systray, Tooltip
rounded = 1
border_width = 0
border_sides = TBLR
border_content_tint_weight = 0
background_content_tint_weight = 0
background_color = #000000 100
border_color = #333333 100
background_color_hover = #000000 100
border_color_hover = #000000 100
background_color_pressed = #000000 100
border_color_pressed = #000000 100

#-------------------------------------
# Panel
panel_items = :P:LTSBC
panel_size = 100% 32
panel_margin = 0 0
panel_padding = 2 0 2
panel_background_id = 3
wm_menu = 1
panel_dock = 0
panel_pivot_struts = 0
panel_position = bottom center horizontal
panel_layer = top
panel_monitor = all
panel_shrink = 0
autohide = 1
autohide_show_timeout = 0
autohide_hide_timeout = 1
autohide_height = 2
strut_policy = follow_size
panel_window_name = tint2
disable_transparency = 1
mouse_effects = 1
font_shadow = 0
mouse_hover_icon_asb = 50 0 10
mouse_pressed_icon_asb = 50 0 10
scale_relative_to_dpi = 0
scale_relative_to_screen_height = 0

#-------------------------------------
# Taskbar
taskbar_mode = single_desktop
taskbar_hide_if_empty = 0
taskbar_padding = 0 0 0
taskbar_background_id = 3
taskbar_active_background_id = 3
taskbar_name = 0
taskbar_hide_inactive_tasks = 0
taskbar_hide_different_monitor = 0
taskbar_hide_different_desktop = 0
taskbar_always_show_all_desktop_tasks = 0
taskbar_name_padding = 2 2
taskbar_name_background_id = 3
taskbar_name_active_background_id = 3
taskbar_name_font = Noto Sans 9
taskbar_name_font_color = #e5a50a 100
taskbar_name_active_font_color = #ffffff 100
taskbar_distribute_size = 0
taskbar_sort_order = none
task_align = left

#-------------------------------------
# Task
task_text = 1
task_icon = 1
task_centered = 1
urgent_nb_of_blink = 100000
task_maximum_size = 150 35
task_padding = 2 2 4
task_font = Noto Sans 10
task_tooltip = 1
task_thumbnail = 0
task_thumbnail_size = 210
task_font_color = #ffffff 100
task_background_id = 3
task_normal_background_id = 3
task_active_background_id = 3
task_urgent_background_id = 3
task_iconified_background_id = 3
mouse_left = toggle_iconify
mouse_middle = none
mouse_right = close
mouse_scroll_up = toggle
mouse_scroll_down = iconify

#-------------------------------------
# System tray (notification area)
systray_padding = 0 4 0
systray_background_id = 5
systray_sort = right2left
systray_icon_size = 26
systray_icon_asb = 100 0 0
systray_monitor = primary
systray_name_filter =

#-------------------------------------
# Launcher
launcher_padding = 2 2 2
launcher_background_id = 3
launcher_icon_background_id = 3
launcher_icon_size = 24
launcher_icon_asb = 100 0 0
launcher_icon_theme_override = 0
startup_notifications = 1
launcher_tooltip = 1

#-------------------------------------
# Clock
time1_format = %H:%M:%S
time2_format = %a, %d %b %Y
time1_font = Noto Sans Semi-Bold 10
time1_timezone =
time2_timezone =
time2_font = Noto Sans 9
clock_font_color = #ffffff 100
clock_padding = 2 2
clock_background_id = 3
clock_tooltip =
clock_tooltip_timezone =
clock_lclick_command =
clock_rclick_command = orage
clock_mclick_command =
clock_uwheel_command =
clock_dwheel_command =

#-------------------------------------
# Battery
battery_tooltip = 1
battery_low_status = 10
battery_low_cmd = xmessage 'tint2: Battery low!'
battery_full_cmd =
bat1_font = Noto Sans 9
bat2_font = Noto Sans 9
battery_font_color = #ffffff 100
bat1_format =
bat2_format =
battery_padding = 2 2
battery_background_id = 3
battery_hide = 101
battery_lclick_command = xfce4-power-manager-settings
battery_rclick_command =
battery_mclick_command =
battery_uwheel_command =
battery_dwheel_command =
ac_connected_cmd =
ac_disconnected_cmd =

#-------------------------------------
# Separator 1
separator = new
separator_background_id = 3
separator_color = #777777 84
separator_style = empty
separator_size = 3
separator_padding = 1 0

#-------------------------------------
# Separator 2
separator = new
separator_background_id = 3
separator_color = #777777 84
separator_style = empty
separator_size = 3
separator_padding = 1 0

#-------------------------------------
# Button 1
button = new
button_text = MinimalistUI
button_lclick_command = rofi -show drun
button_rclick_command =
button_mclick_command =
button_uwheel_command =
button_dwheel_command =
button_font = Noto Sans 9
button_font_color = #ffffff 100
button_padding = 0 0
button_background_id = 3
button_centered = 0
button_max_icon_size = 0

#-------------------------------------
# Tooltip
tooltip_show_timeout = 0.1
tooltip_hide_timeout = 0.1
tooltip_padding = 4 4
tooltip_background_id = 5
tooltip_font_color = #ffffff 100
tooltip_font = Noto Sans 10
EOF'
chmod +x /minui/config/tint2rc > /dev/null 2>&1
# Define the user
TARGET_USER="$NEWUSER"
USER_HOME="/home/$TARGET_USER"

# 1. Create .bash_profile
# Note: Using 'EOF' (with quotes) prevents the current shell from
# evaluating variables like $DISPLAY or $S before they are written.
cat << 'EOF' > "$USER_HOME/.bash_profile"
while true; do
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        read -r -p "Do you want to login into a GUI session or stay in TTY? ('1' for GUI, '0' for TTY): " R
        case $R in
            1)
                declare -A desktops
                [[ -f /usr/bin/startminuix ]] && desktops[MinimalistUI-X11]="startminuix"
                [[ -f /usr/bin/startminuiw ]] && desktops[MinimalistUI-WYL]="startminuiw"
                [[ -f /usr/bin/startxfce4 ]] && desktops[XFCE4]="startxfce4"
                [[ -f /usr/bin/startplasma-x11 ]] && desktops[KDE]="startplasma-x11"
                [[ -f /usr/bin/gnome-session ]] && desktops[GNOME]="gnome-session"
                [[ -f /usr/bin/i3 ]] && desktops[i3]="i3"

                count=${#desktops[@]}

                if [ "$count" -gt 1 ]; then
                    echo "Multiple environments detected:"
                    select choice in "${!desktops[@]}" "Terminal-Only"; do
                        if [[ -n $choice && $choice != "Terminal-Only" ]]; then
                            export S=${desktops[$choice]}
                            exec startx
                        else
                            echo "Aborting GUI launch."
                            break
                        fi
                    done
                elif [ "$count" -eq 1 ]; then
                    # Get the only key in the array
                    B="${!desktops[@]}"
                    export S=${desktops[$B]}
                    exec startx
                else
                    echo "No GUI environments found in /usr/bin/."
                    sleep 2
                fi
                ;;
            0)
                break
                ;;
            *)
                echo "Invalid input."
                continue
                ;;
        esac
    else
        break
    fi
done
EOF

# 2. Create .xinitrc
cat << 'EOF' > "$USER_HOME/.xinitrc"
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# If $S was exported from .bash_profile, run it.
# Otherwise, default to xfce4 or a safe fallback.
if [ -n "$S" ]; then
    exec $S
else
    # Fallback to xfce if installed, otherwise just a terminal
    if [ -f /usr/bin/startminuiw ]; then
        exec startminuiw
    else
        exec xterm
    fi
fi
EOF

# Ensure the new user owns these files
chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.bash_profile" "$USER_HOME/.xinitrc"

[[ -z "$OFFLINE" ]] && ln -sf /minui/config/mpv.conf /home/"$NEWUSER"/.config/mpv/mpv.conf &&
chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/mpv/mpv.conf &&
ln -sf /minui/config/labwc /home/"$NEWUSER"/.config/labwc/autostart &&
chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/labwc/autostart &&
ln -sf /minui/config/tint2.desktop /home/"$NEWUSER"/.config/autostart/tint2.desktop &&
chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/autostart/tint2.desktop &&
ln -sf /minui/config/tint2rc
cp wp.png /minui/backgrounds/wp.png
echo 'export PATH="$PATH:/minui/bin"' >> /home/"$NEWUSER"/.bashrc
exit 0
