#!/bin/bash
Y="" #Empty
A=""
B=""
H=""
M=""
O=""
R=""
V=""
D="/"
E="5"
N="1"
I="$E"
T=$(pwd)
P=$(whoami)
U=$(basename "$T")
Q=$(cat /etc/hostname)
F=$(find . -maxdepth 1 -type f -name "*.iso" | head -n 1)
K=$(basename "$F")
J=$(find . -maxdepth 1 -type f -name "*.sfs" | head -n 1)
L="$A/mnt/sfs0"
X="$A/mnt/iso0"
Z="$A/mnt/iso1"
C="$L/minimalistui/minimalistui.sh"
G="$L/minui"
S="$Z/arch/x86_64/airootfs.sfs"
W="$L/minimalistui"
while true; do
if [[ $EUID -ne 0 ]]; then #1st stage, sudo
    echo "[$P@$Q $U]$ ERROR: Must run with sudo."
    read -r -p "[$P@$Q $U]$ Rerun with sudo? (y/n): " R
    case $R in
    [yY]) exec sudo "$0" "$@" ;;
    "") continue ;;
    *) echo "[$P@$Q $U]$ Exiting."
       exit 1 ;;
    esac
else
    break
fi
done
echo "[$P@$Q $U]# Shell Script (.sh) to automate minui.iso creation."
echo "[$P@$Q $U]# Run this script in the same directory as arch.iso that wanted to be modified to minui.iso."
umount "$X" > /dev/null 2>&1
rm -rf "$X"
rm -rf "$Z"
rm -rf "$L"
mkdir -p "$X"
mkdir -p "$Z"
mkdir -p "$L"
echo "[$P@$Q $U]# Needed free space of atleast 5GB, checking if free space in '"$D"' is enough.  ."
is_fs_larger_than_gib() {
    local H="$1" # Mount point to check (e.g., "/")
    local Y="$2" # Required size in GiB
    local free_size=$(df -BG --output=avail "$H" | tail -n 1 | sed 's/G//')
    if [[ "$free_size" -ge "$Y" ]]; then
        return 0 # Cukup
    else
        return 1 # Kurang
    fi
    }
check_fs_supports_unix_features() {
    local H="$1"
    # Get the filesystem type of the directory using findmnt
    local W="$P"
    local P=$(findmnt -n -o FSTYPE -T "$H")
    # Check against known supporting filesystem types
    case "$P" in
        ext*|btrfs|xfs|zfs|f2fs)
            echo "[$W@$Q $U]# Target FS Type: $P (Unix-like). Hard links supported, using main method."
            return 0
            ;;
        vfat|exfat|ntfs|fuse|fuseblk)
            # Non-Unix filesystems, or generic FUSE mounts which often fail hardlink creation.
            echo "[$W@$Q $U]# Target FS Type: $P (Non-Unix). Hard links not supported, using fallback method."
            return 1
            ;;
        *)
            # Default to safe mode for unknown types or errors
            echo "[$W@$Q $U]# Target FS Type: $P (Unknown/Default). Using fallback method."
            return 1
            ;;
    esac
}
while true; do
    if is_fs_larger_than_gib "$D" "$E"; then
        echo "[$P@$Q $U]# Free space in '"$D"' directory is >${E}GiB, continuing"
        cd "/"
        break
    else
        rm -rf "$X"
        rm -rf "$Z"
        rm -rf "$L"
        A="$T"
        echo "[$P@$Q $U]# ERROR: Free disk space on $D is < ${E}GiB. Will check '"$A"' (current running dir.)."
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
            echo "[$P@$Q $U]# ERROR: Free disk space on $D is < ${E}GiB. Exiting (because "/" and "$A" is < ${E}GiB)."
            break
            exit 1
        fi
    fi
done
    echo "[$P@$Q $U]# Checking target filesystem capabilities for directory: '"$D"'"
    while true; do
    if [[ "$V" == "" && "$I" == "$E" ]]; then
        read -r -p "[$P@$Q $U]# What would you want your bootable .iso version be?: " V #2nd stage, reads
        read -r -p "[$P@$Q $U]# What would you want your bootable .iso output file name be? (don't add file extension): " E
    else
        cd "$T"
        O=""
        I="$E-ce"
        N=""
    fi
    echo "[$P@$Q $U]# Initiating minui.iso creation process." #3rd stage, start
    echo "[$P@$Q $U]# Mounting arch.iso"
    echo "[$P@$Q $U]# Mounting $A/$K as arch.iso in directory /mnt/iso"
    mount "$T/$K" "$X"
    cd "$Z"
    if check_fs_supports_unix_features "$D"; then
        rsync -aH --progress "$X"/ "$Z"
    else
        rsync -rv --no-owner --no-group --no-perms --no-times --no-xattrs --progress "$X"/ "$Z"
    fi
    unsquashfs -f -d "$L" "$S"
    while true; do
    if [[ -z "$Y" ]]; then
        read -r -p "[$P@$Q $U]# Would you like to create 'Creator Edition' (-ce) .iso? (1 for yes, 2 for both, 0 for no (default: no)): " Y
        case $Y in
        1) I="$E-ce"
            N=""
            break ;;
        2) O=(echo "[$P@$Q $U]# re-doing script to create .iso for "-ce""
            continue)
            break ;;
        0) ;;
        "") continue ;;
        esac
    else
        break
    fi
    done
    if [[ -d "$A/minui" && -d "$A/minimalistui" ]]; then
        mv minui "$G"
        mv minimalistui "$W"
        $N
        else
        echo "[$P@$Q $U]# 'minui' and minimalistui.sh is not spotted, using git clone to get both files"
        git clone https://github.com/xv7ranker/minimalistui-extras "$G"
        git clone https://github.com/xv7ranker/minimalistui "$W"
        rm -rf "$W/.git"
        rm -rf "$W/README.md"
        rm -rf "$W/LICENSE"
        if [[ $N == "1" ]]; then
            chmod +x "$W/mkisosfs.sh"
            chmod +x "$W/minui.iso.sh"
            mv "$W/mkisosfs.sh" "$G"
            mv "$W/mkiso.sh" "$G"
        elif [[ $N == "" ]]; then
            rm -rf "$W/mkisosfs.sh"
            rm -rf "$W/mkiso.sh"
        fi
        chmod +x "$G/x.sh"
        chmod +x "$G/c.sh"
        chmod +x "$C"
        mv "$C" "$L/usr/bin/minimalistui.sh"
    fi
    if [[ -d "$G" && -d "$W" ]]; then
        $M
    fi
    cd "$L"
    echo "[$P@$Q $U]# creating .sfs" #4th stage, .sfs $DV
    mksquashfs "." "airootfs.sfs" -comp gzip -b 1M -no-progress
    echo ".sfs creation finished"
    rm -rf "$S"
    mv "$J" "$S"
    cd "$Z"
    echo "[$P@$Q $U]# creating .iso" # 5th stage, .iso
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${I}.iso" -p "xv7ranker" -publisher "xv7ranker" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "."
    echo "[$P@$Q $U]# .iso creation finished"
    cp "$T/$K" ""$T"/$F"
    $O
    umount "$X"
    rm -rf "$X"
    rm -rf "$Z"
    rm -rf "$L"
    echo "[$P@$Q $U]# Script finished. Exiting"
    done
    exit 0
