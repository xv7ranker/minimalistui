#!/bin/bash
if [[ -z "$NULL" ]]; then #0.5th=>8th Stage, The Whole MinimalistUI.sh script, 679 Lines Total, ~25,9 KiB
if [[ -z "$NULL" ]]; then #0.5th Stage, Functions (Used functions: A=>H), 283 Lines, (L3=>L286)
A() { #A function for Temporary leave
while true; do
local opt=$1
[[ "$opt" == "1" ]] && echo "> Welcome to special developer environtment" && echo "> You can enter this very environtment by entering 'D' on every major Stage ('> fdisk:' for e.g.)" && read -r -p "> See special Options:
> '0' to exit,
> '9' to exit to subshell,
> '1' to see every used variabels,
> '2' to see every used functions,
> '3' to modify this script temporarily and return back here,
> '4' to apply temporary modifications permanently,
> Notes: If you are using kate, click the triangle on the left side of the command lines to hide 'if' & 'while true; do' arguments, close the:
'if [[ -z "$NULL" ]]; then' arguments to minimize codes per stage.
> answer: " R
case $R in
[Dd]) echo "> Its not usable here duh... you are already in the developer environtment." && continue;;
0) break && A 9;;
1) echo "> A->F" && continue;;
2) echo "> A->F" && continue;;
3) sudo nano "$0" && exec sudo "$0" "$@" && A 1;;
esac
done
[[ "$opt" == "9" ]] && echo -e "> --- SUSPENDING SCRIPT ---" && echo -e "> You are now in a temporary subshell." && echo -e "> Type 'exit' or press Ctrl+D to return to minimalistui.sh script." && /bin/bash --rcfile <(echo "export PS1='(Installer-Subshell) \w # '") && echo -e "> --- RESUMING SCRIPT ---"
}

B() { #B function for networkings
local opt=$1
${opt:-0}
if [[ "$opt" == 0* ]]; then
echo "> Trying to ping ping.archlinux.org."
curl -I http://google.com > /dev/null 2>&1
if [[ "$?" == "0" ]]; then
    echo "> Internet access obtained, continuing."
cat <<'EOF' > /etc/pacman.conf
[core]
Include = /etc/pacman.d/mirrorlist
[extra]
Include = /etc/pacman.d/mirrorlist
EOF
    TIMEZONE=$(curl -s https://ipapi.co/timezone/)
    echo "> Your Timezone: '$TIMEZONE'"
    timedatectl set-timezone $TIMEZONE
    echo "> Current date & time:"
    timedatectl
else
    echo "> Internet access unobtained, going back."
    return 1
fi
elif [[ "$opt" == 1* ]]; then
    if [[ -d /minui/flatpak/ ]]; then
    while true; do
    echo "> Time will be synchronized when conected to internet, setting timezone."
    read -r -p "> '1' to list timezones (default), and type the timezones to set the timezone (Area/Location (e.g. Asia/Jakarta)): " TIMEZONE
    TIMEZONE="${TIMEZONE:-1}"
    [[ "$TIMEZONE" == 1* ]] && timedatectl list-timezones > t.txt
    echo "Use 'q' button to Quit." >> t.txt
    less timezones.txt
    rm -rf timezones.txt && continue
    [[ ! "$TIMEZONE" == 1* ]] && timedatectl set-timezone $TIMEZONE && break && done
cat <<EOF >> /etc/pacman.conf
[local]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/pkg/
[extralocal]
SigLevel = Optional TrustAll
Server = file:///minui/repos/pacman
EOF
    export OFFLINE="1"
else
    echo "!!! ERROR: Support for offline install is unavailable for this .iso version. Install one with offline support, or have internet access to continue."
    return 1
fi
fi
export A=""
}

C() { #C is for font and keyboard layout change
while true; do
read -r -p "> Change your keyboard layout to:
> '0' to skip,
> '1' to see all options,
> 'us' to set keyboard layout to US (d),
> 'de-latin1' to set keyboard layout to German.
> answer: " R
A=${R:-us}
localectl list-keymaps > k.txt
case $K in
0) rm -rf k.txt;;
1) less k.txt
echo "press 'q' to exit" >> k.txt
rm -rf k.txt
continue;;
"") continue;;
*) if grep -qx "$A" k.txt; then
    loadkeys "$A"
    echo "> Layout '$A' loaded."
    rm -rf k.txt
else
    echo "! ERROR: Keyboard layout '$A' not found, try again."
    rm -rf k.txt
    continue
fi;;
esac
while true; do
read -r -p "> Change your console font to:
> '0' skip,
> '1' see all options,
> 'ter-132b' for HiDPI screens (arch installation guide recomendation).
> answer: " R
case $R in
0) break 2;;
1) ls /usr/share/kbd/consolefonts > f.txt
echo "> Ignore files starting with 'README.'."
echo "When changing font, add the format of the font you want to change to, like if you want to change to iso01.08, you should write iso01.08.gz." >> f.txt
echo "Use 'q' button to Quit." >> f.txt
less f.txt
rm -rf f.txt
continue;;
"") continue ;;
*) FONT_BASE_PATH="/usr/share/kbd/consolefonts/$R"
if [ -f "$FONT_BASE_PATH" ] || [ -f "$FONT_BASE_PATH.psf.gz" ] || [ -f "$FONT_BASE_PATH.psf" ]; then
    setfont $R
    break 2
else
    echo "! ERROR: Console font '$R' not found, try again."
    continue
fi;;
esac
done
done
export A=""
}

D() { #D function for devices & partition stuffs
local opt=$1
if [[ -z "$DEVICE" && -z "$ESPDIR" && -z "$ROOTDIR" || -z "$opt" ]]; then
    declare -A dev
    while read -r path; do
    dev["$path"]="$path"
    done < <(lsblk -n -l -d -y -p -o NAME)
    count=${#dev[@]}
    if [[ "$count" -gt 1 ]]; then
        echo "> Choose one of your devices that MinimalistUI will be installed to:"
        select choice in "${!dev[@]}"; do
        if [[ -z $choice ]]; then
            read -r -p "> Are you sure you want to skip? '1' for yes (Default), '0' for no: " R
            [[ ${R:-1} == 1* ]] && break || continue
        fi
        if [[ -n $choice && $choice ]]; then
            export DEVICE=${dev[$choice]}
            break
            else
            continue
        fi
        done
        elif [[ "$count" -eq 1 ]]; then
        export DEVICE="${!dev[@]}"
    fi
elif [[ "$opt" == 1* ]]; then
    local dev=$2
    local num=$3
    if [[ $dev == *[0-9] ]]; then
        echo "${dev}p${num}"
    else
        echo "${dev}${num}"
    fi
fi
}

E() { #E Is for Wifi Stuffs
iwctl device wlan0 set-property Powered on > /dev/null 2>&1
iwctl station wlan0 scan > /dev/null 2>&1
read -r -p "> Is your wifi hidden (y/n)" R
[[ ${R:-y} == [yY]* ]] && read -r -d '' A <<EOF
iwctl station wlan0 connect-hidden "$SSID"
EOF
[[ ${R:-y} == [nN]* ]] && read -r -d '' A <<EOF
iwctl station wlan0 connect "$SSID" "$SEC"
EOF
declare -A wifi
local choice=()
while read -r line; do
local ssid=$(echo "${line:4:32}" | xargs)
local security=$(echo "${line:36:10}" | xargs)
if [[ -n "$ssid" ]]; then
    wifi["$ssid"]="$security"
    choice+=("$ssid")
fi
[[ -n $ssid ]] && wifi["$ssid"]="$ssid"
done < <(iwctl station wlan0 get-networks | awk 'NR > 4')
echo "> Choose a WiFi network:"
select choice in "${!wifi[@]}"; do
if [[ -z $choice ]]; then
    read -r -p "> Are you sure you want to skip? (y(d)/n): " R
    [[ ${R:-y} == [yY]* ]] && break || continue
fi
export SSID="$choice"
local SEC="${wifi_security[$choice]}"
B="eval $A"
if [ $? -eq 0 ]; then
    echo "> Successfully connected to $SSID"
else
    echo "> Failed to connect to $SSID"
fi
break
done
export A=""
}

F() { #F Function for partitioning stage
echo "> fdisk:
> '1' list disks and partitions,
> '2' create an Empty Partition,
> '3' create an ESP (GPT, part. no. 1),
> '4' create a Root Partition ($CB, part. no. $G),
> '5' create an Empty partition (DIY, interactive),
> '6' create a swapfile (After Root Partition & ESP),
> '7' finish (use after finished creating partitions),
>> current size format used: $CA (enter 'b' to change),
>> current partition format style: $CB (enter 'b' to change),
>>> Notes: Create ESP first before creating Root partition for GPT users, and for MBR users, skip creating ESP"
read -r -p "> answer: " FDISK
export FDISK=$FDISK
}

G() { #G Function to create swapfile (Swap partition alternative)
while true; do
read -r -p "> Do you want to create a swapfile (Alternative to swap partition)? (y/n)" R
[[ -z "$R" ]] && continue
read -r -p "> How much (In $CA) would you like to allocate to your swapfile? (d=8) (no .0 value) " SWAPALLOC
SWAPALLOC=${SWAPALLOC:-8}
[[ "$R" == [yY]* && -z "$BTRFS" ]] && read -r -d SWAPFILE <<'EOF'
local SWAPSIZE=$(( $SWAPALLOC * 1024 ))
dd if=/dev/zero of=/minui/swap/swapfile bs=1M count=$SWAPSIZE status=progress && chmod 600 /minui/swap/swapfile && mkswap /minui/swap/swapfile && swapon /minui/swap/swapfile && echo "/minui/swap/swapfile none swap defaults 0 0" >> /etc/fstab
EOF
[[ "$R" == [yY]* && ! -z "$BTRFS" ]] && read -r -d SWAPFILE <<'EOF'
touch /minui/swap/swapfile && chattr +C /minui/swap/swapfile && fallocate -l ${SWAPALLOC}G /minui/swap/swapfile && chmod 600 /minui/swap/swapfile && mkswap /minui/swap/swapfile && swapon /minui/swap/swapfile && echo "/swap/swapfile none swap defaults 0 0" > /etc/fstab
EOF
break
done
}

H() { #H Function to create a shell script to automate arch-chroot command
cat <<EOF > /mnt/v.sh
declare -r T="$TIMEZONE"
declare -r H="$HOSTNAME"
declare -r NEWUSER="$NEWUSER"
declare -r NEWPASS="$NEWPASS"
declare -r OFFLINE="$OFFLINE"
declare -r BOOTLOADER="$BOOTLOADER"
declare -r SWAPFILE="$SWAPFILE"
EOF
cat <<'EOF' > /mnt/o.sh
#!/bin/bash
source /v.sh
echo "> Entering chroot environtment."
echo "$H" > /etc/hostname
ln -sf /usr/share/zoneinfo/"$T" /etc/localtime
hwclock --systohc
[[ -z "$SWAPFILE" ]] && eval "$SWAPFILE" || echo "> Skipping swapfile creation."
echo "> Creating account."
useradd -m -G wheel,audio,video,storage,power -s /bin/bash "$NEWUSER"
echo "> You can modify root account password using command "passwd" while being root user or "sudo passwd" if you are using user account and you didnt know what your root account password is."
echo "> Set your new user password."
chpasswd <<USEREOF
$NEWUSER:$NEWPASS
USEREOF
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/99_wheel_config
mkdir /home/"$NEWUSER"/media && ln -sf /run/"$NEWUSER" /home/"$NEWUSER"/media
chown -R "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"
chmod +x /home/"$NEWUSER"/.xinitrc
chmod +x /home/"$NEWUSER"/.bash_profile
[[ ! -z "$X" ]] && echo "
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Adwaita" > /home/$NEWUSER/.config/gtk-3.0/settings.ini
[ -d "/minui" ] && sh /minui/x.sh && rm -rf /minui/flatpak
eval "$BOOTLOADER" && echo "> Installing Packages."
sh /extrapacman.sh
sh /extraflatpak.sh
rm -rf /v.sh
EOF
chmod +x /mnt/o.sh
}
fi
if [[ -z "$NULL" ]]; then #1st stage, Introduction, 7 Lines (L287=>L294)
echo "> Shell Script (.sh) to install MinimalistUI."
echo "> Modified settings will be saved to your new installation."
echo "> Legend:
> (d) default option,
> (y/n(d)) yes/no with no as default value,
> (y(d)/n) yes/no with yes as default value,"
fi
if [[ -z "$NULL" ]]; then # 2nd stage, Sudo check, Font, and Keyboard Layout change, 13 Lines (L295=>L308)
while true; do
if [[ $EUID -ne 0 ]]; then
    read -r -p "! ERROR: Must run with sudo. Rerun with sudo? (y(d)/n): " R
    R=${R:-y}
    [[ $R == [dD]* ]] && A 1
    [[ $R == [yY]* ]] && exec sudo "$0" "$@" || echo "! Exiting." && exit 1
else
    break
fi
done
read -r -p "> Do you want to change console keyboard layout and font? (y/n(d)): " R
[[ ${R:-n} == [yY]* ]] && C || echo "> Not Changing Keyboard Layout (Default: US) and Console Font."
fi
if [[ -z "$NULL" ]]; then #3rd stage, Networking, 21 Lines (L309=>L330)
while true; do
read -r -p "> Networking:
> '1' use wifi,
> '2' use ethernet,
> '3' use wwan (WIP(???)),
> '0' to skip networking (Installs offline version of everything in the script).
> answer: " NET
if [[ "$?" == "0" ]]; then
    break
else
    continue
fi
case $NET in
[Dd]) A 1 && break;;
"") continue ;;
0) B 1 && break;;
1) E && B;;
2) B;;
3) B;;
esac
fi
if [[ -z "$NULL" ]]; then #4th stage, 1st stage partitioning, 61 Lines (L331=>L392)
if [[ -z "$DEVICE" ]]; then
    D 0
fi
echo "!!! Partitioning stage reached. You will be asked to Wipe your storage or no,"
echo "!!! '1' to wipe your storage (incl. partitions and datas), "
echo "!!! '0' to not (you can use your earlier partitioning scheme with this option)."
while true; do
read -r -p "!!! Do You Want To Wipe Out Your Storage To Continue? (y/n(d)): " R
if [[ ${R:-n} == [nN]* ]]; then
    while true; do
    read -r -p "> Do You Wanna Use Your Earlier Partition Setup? (y/n): " R
    [[ "$R" == [yY]* ]] && FDISK="Z" && break 1 || FDISK="" && break 1
    done
    break
else
    while true; do
    read -r -p "> Do you want to exit this script temporarily to move important data? (y/n(d)): " R
    if [[ ${R:-n} == [nN]* ]]; then
        break
    else
        A 9
    fi
    break
    done
    while true; do
    read -r -p "!!!!! Are You Sure That You Want To Wipe Out Your Disk? (y/n(d)): " R
    if [[ ${R:-n} == [nN]* ]]; then
        read -r -p "> Do You Wanna Use Your Earlier Partition Setup? (y/n): " R
        [[ "$R" == [yY]* ]] && FDISK="Z" && break 1 || FDISK="" && break 1
        break
    else
        echo "!!!!! Wiping '$DEVICE'"
        sudo wipefs -a $DEVICE && break
    fi
    done
fi
done
while true; do
read -r -p "> In what size format would you like your new partitions be made?
> '1' use MiB,
> '2' use GiB (d),
> '3' use TiB.
> answer: " SIFORMT
SIFORMT=${SIFORMT:-2}
if [[ "$R" == 2* ]]; then
    CA="GiB" && B="G" && break
elif [[ "$R" == 1* ]]; then
    CA="MiB" && B="M" && break
elif [[ "$R" == 3* ]]; then
    CA="TiB" && B="T" && break
fi
done
while true; do
read -r -p "> GPT (1(d)) or MBR (0) " GPT
GPT=${GPT:-1}
case $GPT in
0) F="83" && E="dos" && CB="GPT" && break;;
1) F="0FC63DAF-8483-4772-8E79-3D69D8477DE4" && E="gpt" && CB="MBR" && break;;
*) continue;;
esac && done
fi
if [[ -z "$NULL" ]]; then #5th stage, 2nd stage partitioning, 162 Lines (L393=>L556)
while true; do
if [[ "$FDISK" == "Z" ]]; then
if [[ -z "$ESPDIR" ]]; then
    while true; do
    if [[ -z "$ESPDIR" ]]; then
        read -r -p "> Enter the full path for the ESP (e.g., /dev/sda1) ('1' to see all options): " ESPDIR
        [[ -z "$ESPDIR" ]] && continue
        [[ "$ESPDIR" == 1* ]] && lsblk && continue || break 2
    fi
fi
if [[ -z "$ROOTDIR" ]]; then
    while true; do
    read -r -p "> Enter the full path for the ROOT partition (e.g., /dev/sda2): " ROOTDIR
    [[ -z "$ROOTDIR" ]] && continue
    [[ "$ROOTDIR" == 1* ]] && lsblk && continue || break 2
    break 1
    done
fi
read -r -p "> Are these paths correct? (y/n)
> Root Partition: $ROOTDIR
> EFI System Partition: $ESPDIR
> answer: " R
[[ "$R" == [yY]* ]] && break || continue && FDISK=""
done
elif [[ ! "$FDISK" == "Z" ]]; then
FDISK="" && export CA CB G && F && case $FDISK in

[bB])
while true; do
read -r -p "> In what size format would you like your new partitions be made?
> '1' use MiB,
> '2' use GiB (d),
> '3' use TiB.
> answer: " SIFORMT
SIFORMT=${SIFORMT:-2}
if [[ "$R" == 2* ]]; then
    CA="GiB" && B="G" && break
elif [[ "$R" == 1* ]]; then
    CA="MiB" && B="M" && break
elif [[ "$R" == 3* ]]; then
    CA="TiB" && B="T" && break
fi
done
while true; do
read -r -p "> GPT (1(d)) or MBR (0) " GPT
GPT=${GPT:-1}
case $GPT in
0) G="1" && F="83" && E="dos" && CB="MBR" && break;;
1) G="2" && F="0FC63DAF-8483-4772-8E79-3D69D8477DE4" && E="gpt" && CB="GPT" && break;;
*) continue;;
esac && done;;

1) lsblk && continue ;;

2)
while true; do
read -r -p "> What name would you like to give to your new partition? (d=NEWPART)" J
J=${J:-NEWPART}
read -r -p "> How much (in $CA) would you like to allocate to your new partition? " H
[[ -z "$H" ]] && continue
read -r -p "> What partition number would you give to your new partition? " G
[[ -z "$G" ]] && continue
done
I=${H}$B
export DEVICE E B I F G J
sudo sfdisk $DEVICE --append --force --quiet <<EOF
label: $E
unit: $B
$G : size=$I, type=$F, name="$J"
EOF
NEWPART=$(D 1 "$DEVICE" "$G")
while true; do
read -r -p "> Choose the format for your new partition
> '1' F2FS, recomended for ssds... supposedly,
> '2' BTRFS, modern, feature-rich...,
> '3' XFS, recomended for big files... supposedly,
> '4' EXT4, classic...,
> '5' FAT12,
> '6' FAT16,
> '7' FAT32.
> answer: " R
case $R in
1) FORMAT="mkfs.f2fs" && break;;
2) FORMAT="mkfs.btrfs" && break;;
3) FORMAT="mkfs.xfs" && break;;
4) FORMAT="mkfs.ext4" && break;;
5) FORMAT="mkfs.fat -F 12" && break;;
6) FORMAT="mkfs.fat -F 16" && break;;
7) FORMAT="mkfs.fat -F 32" && break;;
*) continue ;;
esac && done
echo "> Creating partition at: $NEWPART" && $FORMAT $NEWPART && continue;;

3)
while true; do
read -r -p "> What name would you like to give to your new partition? (d=ESP)" J
J=${J:-ESP}
read -r -p "> How much (in $CA) would you like to allocate to your new partition? " H
[[ -z "$H" ]] && continue
done
I=${H}$B
export DEVICE B I J
sudo sfdisk $DEVICE --append --force --quiet <<EOF
label: gpt
unit: $B
1 : size=$I, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="$J"
EOF
ESPDIR=$(D 1 "$DEVICE" 1)
while true; do
read -r -p "> Choose the format for your new partition
> '1' FAT12,
> '2' FAT16,
> '3' FAT32.
> answer: " R
case $R in
1) FORMAT="mkfs.fat -F 12" && break;;
2) FORMAT="mkfs.fat -F 16" && break;;
3) FORMAT="mkfs.fat -F 32" && break;;
*) continue ;;
esac && done
echo "> Creating partition at: $ESPDIR" && $FORMAT $ESPDIR && continue;;

4)
while true; do
read -r -p "> What name would you like to give to your new partition? (d=ESP)" J
J=${J:-ESP}
read -r -p "> How much (in $CA) would you like to allocate to your new partition? " H
[[ -z "$H" ]] && continue
done
I=${H}$B
export DEVICE E B I F G J
sudo sfdisk $DEVICE --append --force --quiet <<EOF
label: $E
unit: $B
$G : size=$I, type=$F, name="$J"
EOF
ROOTDIR=$(D 1 "$DEVICE" $G)
while true; do
read -r -p "> Choose the format for your new partition
> '1' F2FS, recomended for ssds... supposedly,
> '2' BTRFS, modern, feature-rich...,
> '3' XFS, recomended for big files... supposedly,
> '4' EXT4, classic...,
> answer: " R
case $R in
1) FORMAT="mkfs.f2fs" && break;;
2) FORMAT="mkfs.btrfs" && BTRFS="1" && break;;
3) FORMAT="mkfs.xfs" && break;;
4) FORMAT="mkfs.ext4" && break;;
*) continue ;;
esac && done
echo "> Creating partition at: $ROOTDIR" && $FORMAT $ROOTDIR && continue;;

5) cfdisk && continue;;

6) G && continue;;

7) FDISK="Z" && continue;;

esac
done
fi
fi
if [[ -z "$NULL" ]]; then #6th stage, 1st install stage, 28 Lines (L557=>L586)
read -r -p "> What username would you like to have? : " NEWUSER
read -r -p "> What password would you like to have for your new user? : " NEWPASS
read -r -p "> What hostname would you like to have? : " HOSTNAME
while true; do
read -r -p "> Which bootloader would you like to use? '1' for grub (Universal), '0' for systemd (Default, GPT/EFI only)" R
R=${R:-0}
if [[ $R == 0* ]]; then
while true; do
read -r -p "> Do you want to be able to modify boot entries when bootup? (y(d)/n) " R
R=${R:-y}
[[ "$R" == [Yy]* ]] && EDITABLE="1" || EDITABLE=""
break
done
read -r -d '' BOOTLOADER <<'EOF'
bootctl install
EOF
break
elif [[ $R == 1* && ! -z "$ESPDIR" ]]; then
read -r -d '' BOOTLOADER <<'EOF'
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB && grub-mkconfig -o /boot/grub/grub.cfg
EOF
BL="grub" && break
elif [[ $R == 1* && -z $GPT && ! -z "$ESPDIR" ]]; then
read -r -d '' P <<'EOF'
grub-install --target=i386-pc $D && grub-mkconfig -o /boot/grub/grub.cfg
EOF
BL="grub" && break
fi && done &&
fi
if [[ -z "$NULL" ]]; then #7th stage, 2nd install stage, 12 Lines (L587=>L599)
mkdir -p /mnt && mount "$ROOTDIR" /mnt && ROOT_PART=$(findmnt -n -o SOURCE /mnt) && ROOT_UUID=$(blkid -s UUID -o value $ROOT_PART) && [[ ! -z "$ESPDIR" ]] && mkdir -p /mnt/boot && mount "$ESPDIR" /mnt/boot && cp -r /minui /mnt/minui && cp -r /var/lib/iwd/ /mnt/var/lib/iwd/ && cp -r /etc/NetworkManager/system-connections/ /mnt/etc/NetworkManager/system-connections/ && cp -r /etc/vconsole.conf /mnt/etc/vconsole.conf && cp -r /etc/locale.conf /mnt/etc/locale.conf && [[ -z "$BL" ]] && echo "default minui.conf
timeout 4
console-mode max" > /mnt/boot/loader/loader.conf && echo "
title MinimalistUI
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options nvme_load=YES nowatchdog root=UUID=$ROOT_UUID rw loglevel=3 swapfile=/swapfile" > /mnt/boot/loader/entries/minui.conf && echo "
title MinimalistUI (CLI)
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options nvme_load=YES nowatchdog root=UUID=$ROOT_UUID rw loglevel=3 swapfile=/swapfile systemd.unit=multi-user.target" > /mnt/boot/loader/entries/minuicli.conf && [[ "$EDITABLE" == "" ]] && echo "editor no" >> /mnt/boot/loader/loader.conf || echo "editor yes" >> /mnt/boot/loader/loader.conf
fi
if [[ -z "$NULL" ]]; then #8th stage, 3rd install stage, 72 Lines (L600=>L675)
while true; do
[[ -z "$OFFLINE" ]] && EXTRAPACMAN="pacstrap -K fzf bat zoxide neovim lf thefuck kate gparted lutris steam mangohud firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman network-manager-applet udisks2 gvfs kitty fastfetch cpufetch htop papirus-icon-theme flatpak mpd materia-gtk-theme mpv bash-completion kvantum labwc swaybg mako waybar fuzzel grim slurp wl-clipboard kanshi playerctl"
[[ ! -z "$OFFLINE" ]] && EXTRAPACMAN="pacstrap -c fzf bat zoxide neovim lf thefuck kate gparted lutris steam mangohud firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman network-manager-applet udisks2 gvfs kitty fastfetch cpufetch htop papirus-icon-theme flatpak mpd materia-gtk-theme mpv bash-completion kvantum labwc swaybg mako waybar fuzzel grim slurp wl-clipboard kanshi playerctl"
cat <<'EOF' > /mnt/extrapacman.sh
#!/bin/bash
source /v.sh
mkdir -p /home/"$NEWUSER"/.config/gtk-3.0
cat <<EOT > /home/"$NEWUSER"/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Materia-dark-compact
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Adwaita
EOT
echo "fastfetch" >> /home/"$NEWUSER"/.bashrc
echo "cpufetch" >> /home/"$NEWUSER"/.bashrc
chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/.config
KVANTUM_CONFIG_PATH="/home/$NEWUSER/.config/Kvantum" && KVANTUM_CONFIG_FILE="$KVANTUM_CONFIG_PATH/kvantum.kvconfig"
mkdir -p "$KVANTUM_CONFIG_PATH"
echo -e "[General]\ntheme=Breeze-Dark" > "$KVANTUM_CONFIG_FILE"
chown -R "$NEWUSER":"$NEWUSER" "$KVANTUM_CONFIG_PATH"
echo "export QT_QPA_PLATFORMTHEME=kvantum"
sudo -u "$NEWUSER" tee -a /home/"$NEWUSER"/.profile > /dev/null"
EOF
chmod +x /mnt/extrapacman.sh
cat <<'EOF' > /mnt/extraflatpak.sh
#!/bin/bash
EOF
[[ -z "$OFFLINE" ]] && echo "sudo -u ''$NEWUSER' flatpak --noninteractive --user -y install org.vinegarhq.Sober us.zoom.Zoom com.rtosta.zapzap org.telegram.desktop" >> /mnt/extraflatpak.sh
[[ ! -z "$OFFLINE" ]] && echo "flatpak install --sideload-repo=/minui/flatpak/ flathub com.rtosta.zapzap org.telegram.desktop" >> /mnt/extraflatpak.sh
chmod +x /mnt/extraflatpak.sh
read -r -p "> Would you like to install extra packages (you can go to https://github.com/xv7ranker/minimalistui to see every packages (including extras))?
> '1' install all extra packages (Recomended, tho optional (Incl. Support for wayland)),
> '2' install extra pacman packages (Incl. Support for wayland),
> '3' install extra flatpak packages,
> '0' do not install extra packages.
> answer: " R
case $R in
1) break;;
2) echo '> skipping installing extra flatpak packages.' && rm -rf /mnt/extraflatpak.sh && break;;
3) EXTRAPACMAN="echo '> skipping installing extra pacman packages.'" && rm -rf /mnt/extrapacman.sh && break;;
0) EXTRAPACMAN="echo '> skipping installing extra pacman packages.'" && echo '> skipping installing extra flatpak packages.' && rm -rf /mnt/extraflatpak.sh && rm -rf /mnt/extrapacman.sh && break;;
*) continue ;;
esac && done
VENDORID=$(grep 'vendor_id' /proc/cpuinfo | head -n 1 | awk '{print $NF}')
[[ "$VENDORID" == "GenuineIntel" ]] && CPU="intel-ucode" && echo "> CPU is Intel, installing $CPU"
[[ "$VENDORID" == "AuthenticAMD" ]] && CPU="amd-ucode" && echo "> CPU is AMD, installing $CPU"
while true; do
read -r -p "> Which GPU driver would you like to install?
> '1' to install AMD GPU Driver (Modern (xf86-video-amdgpu)) + Vulkan (vulkan-radeon) + Mesa (Depend.),
> '2' to install AMD GPU Driver (Old (xf86-video-ati)) + Mesa (Default),
> '3' to install Intel GPU Driver (xf86-video-intel) + Vulkan (vulkan-intel) + Mesa (Depend.) + Media Driver (Extra),
(Compatible w/ older non-vulkan igps),
> '4' to install NVIDIA GPU Driver (Proprietary (nvidia-dkms + nvidia-settings)) + Vulkan (Incl.) Mesa (Default),
> '5' to install NVIDIA GPU Driver (Open Source (xf86-video-nouveau)) + Mesa (Default) (No Vulkan (???)),
> '6' to install Generic Fallback Driver (NOT RECOMENDED FOR NEWER SYSTEMS, USE AS FALLBACK ONLY) (xf86-video-vesa) + Mesa (Default),
> '7' to install ALL GPU Drivers (Incl. Mesa & Media Drivers) & CPU Microcodes (Overrides) (Commonly heavier).
> answer: " R
case $R in
1) GPU="xf86-video-amdgpu vulkan-radeon" && break;;
2) GPU="xf86-video-ati" && break;;
3) GPU="xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver" && break;;
4) GPU="nvidia-dkms nvidia-settings nvidia-utils linux-zen-headers" && break;;
5) GPU="xf86-video-nouveau" && break;;
6) GPU="xf86-video-vesa" && break;;
7) GPU="xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon linux-zen-headers" && CPU="intel-ucode amd-ucode" && break;;
*) continue;;
esac && done
[[ -z "$OFFLINE" ]] && pacstrap -K /mnt base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs ntfs-3g unzip p7zip unrar gufw ufw squashfs-tools sudo git pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh gst-plugin-pipewire $GPU $CPU $BL && eval "$EXTRAPACMAN" && genfstab -U /mnt >> /mnt/etc/fstab && H && arch-chroot /mnt <<EOF
sh o.sh && rm -rf o.sh
EOF
[[ ! -z "$OFFLINE" ]] && pacstrap -c /mnt base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs ntfs-3g unzip p7zip unrar gufw ufw squashfs-tools sudo git pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh gst-plugin-pipewire $GPU $CPU $BL && eval "$EXTRAPACMAN" && genfstab -U /mnt >> /mnt/etc/fstab && H && arch-chroot /mnt <<EOF
sh o.sh && rm -rf o.sh
EOF
fi
fi
