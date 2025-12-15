#!/bin/bash
echo "Shell Script (.sh) to automate .iso and .sfs creation" # by xv7ranker
echo "Run the command in the same directory as the contents of the .iso or the .sfs for comfortability"
while true; do
read -r -p "What would you like to create?
- '1' to create .iso,
- '2' to create .iso and .sfs,
- '3' to create .sfs,
- '0' to exit.
- answer: " W
case $W in
1)  read -r -p "What would you want your bootable .iso version be? (have not much effect): " V
    read -r -p "What would you want your bootable .iso output file name be? (have not much effect): " I
    read -r -p "What would you want your bootable .iso preparer name be? (have not much effect): " R
    read -r -p "What would you want your bootable .iso publisher name be? (have not much effect): " B
    while true; do
    read -r -p "Where is the directory to your .iso file contents? (leave empty if you are in the same directory as the contents, include the directory if the .iso file contents are not in the same directory as you are currently running the command in.): " S
    case $S in
    "") S="." ;;
    *) S="$S";;
    esac
    echo "creating .iso"
    xorriso -as mkisofs -D -r -J -l -V "$V" -o "${I}.iso" -p "$R" -publisher "$B" -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/syslinux/isolinux.bin -c boot/syslinux/boot.cat -eltorito-alt-boot -e EFI/BOOT/BOOTx64.EFI -no-emul-boot -isohybrid-mbr  boot/syslinux/isohdpfx.bin "$S"
    echo ".iso creation finished"
    while true; do
    read -r -p 'Would you like to exit {0} or would you like to continue {1}?: ' CO
    case $CO in
    0) exit 0 ;;
    1) break 2 ;;
    *) continue ;;
    esac
    done ;;
2)  read -r -p "What would you want your bootable .iso version be? (have not much effect): " V
    read -r -p "What would you want your bootable .iso and .sfs output file name be? (have not much effect): " I
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
    - '1' gzip (less compression, faster),
    - '2' xz (better compression, slower),
    - '0' none.
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
    read -r -p 'Would you like to exit {0} or would you like to continue {1}?: ' CO
    case $CO in
    0) exit 0 ;;
    1) break 2 ;;
    *) continue ;;
    esac
    done ;;
3)  read -r -p "What would you want your .sfs output file name be? (have not much effect): " I
    EX=""
    while true; do
    read -r -p "Where is the directory to your .sfs file contents? (leave empty if you are in the same directory as the contents, include the directory if the .sfs file contents are not in the same directory as you are currently running the command in.): " S
    case $S in
    "") S="." ;;
    *) S="$S";;
    esac
    read -r -p "What compression algorithm would you like to use?
    - '1' gzip (less compression, faster),
    - '2' xz (better compression, slower),
    - '0' none.
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
    read -r -p 'Would you like to exit {0} or would you like to continue {1}?: ' O
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
