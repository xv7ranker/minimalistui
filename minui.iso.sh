#!/bin/bash
echo "Shell Script (.sh) to automate minui.iso creation."
echo "Run this script in the same directory as arch.iso. and minui folder (make sure there are no more than 1 .iso in the same directory"
A=$(pwd)
X="/mnt/iso0"
Z="/mnt/iso1"
L="/mnt/sfs0"
S="$Z/arch/x86_64/airootfs.sfs"
G="$L/minui"
C="$L/minimalistui.sh"
DV=""
M=$(find . -maxdepth 1 -type f -name "*.iso" | head -n 1)
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
    echo "Needed free space of atleast 5GB, checking if free space in disk is enough."
is_fs_larger_than_gib() {
    local H="$1"
    local Y="$2"
    df -BG -P | awk -v mp="$H" -v threshold="$Y" '
        NR > 1 && $6 == mp {
            free_size = $4;
            sub(/G/, "", free_size);
            if (free_size >= threshold) {

                exit 0
            } else {
                exit 1
            }
            END {
            if (NR <= 1 || $6 != mp) {
                exit 1
            }
        }'
    return $?
    }
    echo "Free disk space is >5GB, continuing"
    read -r -p "What would you want your bootable .iso version be?: " V #2nd stage, read
    read -r -p "What would you want your bootable .iso output file name be? (don't add file extension): " I
    read -r -p "Would you like to use fancy mode (no command looks, 1) or default (running commands are visible, 0)? " FC
    case $FC in
    1) DV="> /dev/null" ;;
    *) ;;
    esac
    echo "Initiating minui.iso creation process." #3rd stage, start
    echo "Mounting arch.iso"
    echo "Mounting $M as arch.iso in directory /mnt/iso"
    mkdir -p $X $DV
    mkdir -p $Z $DV
    mkdir -p $L $DV
    mount $M $X $DV
    cp -a $X/. $Z $DV
    cd $Z $DV
    unsquashfs -f -d $L $S $DV
    RC=""
    RM="
    rm -rf $L/mkisosfs.sh $DV 
    rm -rf $L/minui.iso.sh $DV"
    read -r -p "Would you like to create 'Creator Edition' (-ce) .iso? (1 for yes, 0 for no (default: no))" Y
    case $Y in
    1) IM="$I-ce" 
        RM="" 
        RC="
        mv $L/mkisosfs.sh $DV
        mv $L/minui.iso.sh $DV" ;;
    *) IM="$I" ;;
    esac
    if [[ -d "$A/minui" && -f "$A/minimalistui.sh" ]]; then
      mv minui $G $DV
      mv minimalistui.sh $C $DV
      $RC
    else
      echo "'minui' and minimalistui.sh is not spotted, using git clone to get both files"
      git clone https://github.com/xv7ranker/minimalistui-extras $G $DV
      git clone https://github.com/xv7ranker/minimalistui $L $DV
      rm -rf $L/.git $DV
      rm -rf $L/README.md $DV
      rm -rf $L/LICENSE $DV
      $RM
    fi
    chmod +x $L/minui/x.sh $DV
    chmod +x $L/minui/c.sh $DV
    chmod +x $C $DV
    mv $C $L/usr/bin/minimalistui.sh $DV
    $RC
    cd $L $DV
    echo "creating .sfs" #4th stage, .sfs $DV
    mksquashfs "." "airootfs.sfs" -comp gzip -b 1M -no-progress $DV
    echo ".sfs creation finished" $DV
    J=$(find . -maxdepth 1 -type f -name "*.sfs" | head -n 1) $DV
    rm -rf $S $DV
    mv $J $S $DV
    cd $Z $DV
    echo "creating .iso" # 5th stage, .iso
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${I}.iso" -p "xv7ranker" -publisher "xv7ranker" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "." $DV
    echo ".iso creation finished"
    F=$(find . -maxdepth 1 -type f -name "*.iso" | head -n 1) $DV
    K=$(basename "$F") $DV
    cp $K "$A"/$K $DV
    umount $X $DV
    rm -rf $X $DV
    rm -rf $Z $DV
    rm -rf $L $DV
    echo "Script finished. Exiting"
    exit 0
