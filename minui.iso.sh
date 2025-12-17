#!/bin/bash
echo "Shell Script (.sh) to automate minui.iso creation."
echo "Run this script in the same directory as arch.iso. and minui folder (make sure there are no more than 1 .iso in the same directory"
A=$(pwd)
B=""
C="$L/minimalistui.sh"
D="/"
E="5"
F=$(find . -maxdepth 1 -type f -name "*.iso" | head -n 1)
G="$L/minui"
H=""
I="$E"
J=$(find . -maxdepth 1 -type f -name "*.sfs" | head -n 1)
K=$(basename "$F")
L="$A/mnt/sfs0"
M=(
rm -rf "$L/mkisosfs.sh"
rm -rf "$L/minui.iso.sh")
N=""
O=""
P="" # empty
R=""
S="$Z/arch/x86_64/airootfs.sfs"
V=""
X="$A/mnt/iso0"
Z="$A/mnt/iso1"
while true; do
if [[ $EUID -ne 0 ]]; then #1st stage, sudo
    echo "ERROR: Must run with sudo."
    read -r -p "Rerun with sudo? (y/n): " R
    case $R in
    [yY]) exec sudo "$0" "$@" ;;
    "") continue ;;
    *) echo "Exiting."
       exit 1 ;;
    esac
else
    break
fi
done
    echo "Needed free space of atleast 5GB, checking if free space in disk is enough. checking '/' ."
is_fs_larger_than_gib() {
    local H="$1" # Mount point to check (e.g., "/")
    local Y="$2" # Required size in GiB
    # Check free space on the specified mount point using a robust, single-line AWK command.
    # It checks if the free size ($4) for the target mount point ($6) is >= the threshold.
    df -BG -P | awk -v mp="$H" -v threshold="$Y" 'NR > 1 && $6 == mp { free_size = $4; sub(/G/, "", free_size); exit (free_size >= threshold ? 0 : 1) } END { if (NR <= 1) exit 1 }'
    return $?
}
check_fs_supports_unix_features() {
    local H="$1"
    # Get the filesystem type of the directory using findmnt
    local P
    P=$(findmnt -n -o FSTYPE -T "$H")
    # Check against known supporting filesystem types
    case "$P" in
        ext*|btrfs|xfs|zfs|f2fs)
            echo "Target FS Type: $P (Unix-like). Hard links supported."
            return 0
            ;;
        vfat|exfat|ntfs|fuse|fuseblk)
            # Non-Unix filesystems, or generic FUSE mounts which often fail hardlink creation.
            echo "Target FS Type: $P (Non-Unix). Hard links NOT supported."
            return 1
            ;;
        *)
            # Default to safe mode for unknown types or errors
            echo "Target FS Type: $P (Unknown/Default). Using ultra-safe mode."
            return 1
            ;;
    esac
}
while true; do
    if is_fs_larger_than_gib "$D" "$E"; then
        echo "Free space in '"$D"' directory is >${E}GiB, continuing"
        break
    else
        # The return code from the function is non-zero, indicating insufficient space or error
        if [[ "$D" == "/" ]]; then
            echo "ERROR: Free disk space on $D is < ${E}GiB. Will check "$A" (current running dir.)."
            D="$A"
            continue
        else
            echo "ERROR: Free disk space on $D is < ${E}GiB. Exiting (because / and current running directory is < ${E}GiB)."
            break
            exit 1
        fi

    fi
done
    echo "Checking target filesystem capabilities for directory: $D"
    if check_fs_supports_unix_features "$D"; then
        R=(rsync -aH --progress "$X"/ "$Z")
    else
        R=(rsync -rv --no-owner --no-group --no-perms --no-times --no-xattrs "$X"/ "$Z")
    fi
    while true; do
    if [[ -z "$V" && -z "$I" ]]; then
        read -r -p "What would you want your bootable .iso version be?: " V #2nd stage, reads
        read -r -p "What would you want your bootable .iso output file name be? (don't add file extension): " E
        break
    fi
    done
    echo "Initiating minui.iso creation process." #3rd stage, start
    echo "Mounting arch.iso"
    echo "Mounting $F as arch.iso in directory /mnt/iso"
    mkdir -p "$X"
    mkdir -p "$Z"
    mkdir -p "$L"
    mount "$F" "$X"
    $R
    cd "$Z"
    unsquashfs -f -d "$L" "$S"
    while true; do
    if [[ -z "$Y" ]]; then
        read -r -p "Would you like to create 'Creator Edition' (-ce) .iso? (1 for yes, 2 for both, 0 for no (default: no)): " Y
        case $Y in
        1) I="$E-ce"
            M=""
            N="
            mv "$L/mkisosfs.sh" "$L/minui"
            mv "$L/minui.iso.sh" "$L/minui""
            break ;;
        2) O=(echo "re-doing script to create .iso for "-ce""
            continue)
            break ;;
        0) ;;
        "") continue ;;
        esac
    else
        break
    fi
    done
    if [[ -d "$A/minui" && -f "$A/minimalistui.sh" ]]; then
      mv minui "$G"
      mv minimalistui.sh "$C"
      $N
    else
      echo "'minui' and minimalistui.sh is not spotted, using git clone to get both files"
      git clone https://github.com/xv7ranker/minimalistui-extras "$G"
      git clone https://github.com/xv7ranker/minimalistui "$L"
      rm -rf "$L/.git"
      rm -rf "$L/README.md"
      rm -rf "$L/LICENSE"
      $M
    fi
    chmod +x "$G/x.sh"
    chmod +x "$G/c.sh"
    chmod +x "$C"
    mv "$C" "$L/usr/bin/minimalistui.sh"
    $N
    cd "$L"
    echo "creating .sfs" #4th stage, .sfs $DV
    mksquashfs "." "airootfs.sfs" -comp gzip -b 1M -no-progress
    echo ".sfs creation finished"
    $J
    rm -rf "$S"
    mv "$J" "$S"
    cd "$Z"
    echo "creating .iso" # 5th stage, .iso
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${I}.iso" -p "xv7ranker" -publisher "xv7ranker" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "."
    echo ".iso creation finished"
    $F
    $K
    cp "$F" ""$A"/$F"
    $O
    umount "$X"
    rm -rf "$X"
    rm -rf "$Z"
    rm -rf "$L"
    echo "Script finished. Exiting"
    done
    exit 0
