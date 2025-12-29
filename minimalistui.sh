#!/bin/bash
S() {
    echo -e "> --- SUSPENDING SCRIPT ---"
    echo -e "> You are now in a temporary subshell."
    echo -e "> Type 'exit' or press Ctrl+D to return to minimalistui.sh script."
    # Launch a new interactive bash session
    /bin/bash --rcfile <(echo "export PS1='(Installer-Subshell) \w # '")
    echo -e "> --- RESUMING SCRIPT ---\n"
}

I() {
    echo "> Trying to ping ping.archlinux.org."
    curl -I http://google.com > /dev/null 2>&1
    if [[ "$?" == "0" ]]; then
        echo "> Internet access obtained, continuing."
cat <<'EOF' > /etc/pacman.conf
[core]
Include = /etc/pacman.d/mirrorlis
[extra]
Include = /etc/pacman.d/mirrorlist
EOF
        T=$(curl -s https://ipapi.co/timezone/)
        echo "> Your Timezone: '$T'"
        timedatectl set-timezone $T
        echo "> Current date & time:"
        timedatectl
    else
        echo "> Internet access unobtained, going back."
        return 1
    fi
}

N() {
    local dev=$1
    local num=$2
    if [[ $dev == *[0-9] ]]; then
        echo "${dev}p${num}"
    else
        echo "${dev}${num}"
    fi
# Usage:
# DD=$(NON "$D" "$N")
}

D() {
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
export D=${dev[$choice]}
break
else
continue
fi
done
elif [[ "$count" -eq 1 ]]; then
export D="${!dev[@]}"
fi
}

E() {
iwctl device wlan0 set-property Powered on > /dev/null 2>&1
iwctl station wlan0 scan > /dev/null 2>&1
if [[ "$LY" == "1" ]]; then
iwctl station wlan0 scan && iwctl station wlan0 get-networks
export LY=""
fi
if [[ "$LY" == "2" ]]; then
read -r -p "> Input Hidden Wifi SSID: " choice
export LY=""
fi
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
read -r -p "> Are you sure you want to skip? '1' for yes (Default), '0' for no: " R
[[ ${R:-1} == 1* ]] && break || continue
fi
export SSID="$choice"
local SEC="${wifi_security[$choice]}"
iwctl station wlan0 connect "$SSID"
if [ $? -eq 0 ]; then
    echo "> Successfully connected to $SSID"
else
    echo "> Failed to connect to $SSID"
fi
break
done
}

C() {
while true; do
read -r -p "> Change your keyboard layout to:
> '0' to skip,
> '1' to see all options,
> 'us' to set keyboard layout to US (Default),
> 'de-latin1' to set keyboard layout to German.
> answer: " RK
K=${RK:-us}
localectl list-keymaps > k.txt
case $K in
0) rm -rf k.txt;;
1) less k.txt && echo "press 'q' to exit" >> k.txt && rm -rf k.txt && continue;;
"") continue;;
*) if grep -qx "$K" k.txt; then
loadkeys "$K"
echo "> Layout '$K' loaded."
rm -rf k.txt
else
echo "! ERROR: Keyboard layout '$K' not found, try again."
rm -rf k.txt
continue
fi
esac
while true; do
read -r -p "> Change your console font to:
> '0' skip,
> '1' see all options,
> 'ter-132b' for HiDPI screens (arch installation guide recomendation).
> answer: " C
case $C in
0) break 2 ;;
1) ls /usr/share/kbd/consolefonts > f.txt && echo "> Ignore files starting with 'README.'." && echo "When changing font, add the format of the font you want to change to, like if you want to change to iso01.08, you should write iso01.08.gz." >> f.txt && echo "Use 'q' button to Quit." >> f.txt && less f.txt && rm -rf f.txt && continue ;;
"") continue ;;
*) FONT_BASE_PATH="/usr/share/kbd/consolefonts/$C"
if [ -f "$FONT_BASE_PATH" ] || [ -f "$FONT_BASE_PATH.psf.gz" ] || [ -f "$FONT_BASE_PATH.psf" ]; then
setfont $C
break 2
else
echo "! ERROR: Console font '$C' not found, try again."
continue
fi ;;
esac
done
done
}

T() {
while true; do
echo "> Time will be synchronized when conected to internet, setting timezone."
read -r -p "> '1' to list timezones (default), and type the timezones to set the timezone (Area/Location (e.g. Asia/Jakarta)): " TA
T="${TA:-1}"
[[ "$T" == 1* ]] && timedatectl list-timezones > t.txt && echo "Use 'q' button to Quit." >> t.txt && less timezones.txt && rm -rf timezones.txt && continue || timedatectl set-timezone $T && break && done
}

R() {
read -r -p "> fdisk:
> '1' see all options,
> '2' list partitions and disks,
> '3' create Empty Partition,
> '4' create ESP (GPT, part. no. 1),
> '5' create Root Partition (GPT/MBR, part. no. (1 for mbr, 2 for gpt)),
> '6' create Empty partition (DIY, interactive),
> '7' create Subvolumes (for btrfs),
> '8' finish (use after finished creating partitions),
> current size format used: '$B' (enter 'b' to change),
> notes: create ESP first before creating Root partition for GPT users, and for MBR users, skip creating boot partition / ESP
> answer: " RA
return $RA
}

L() {
cat <<EOF > /mnt/v.sh
export T="$T"
export H="$H"
export NEWUSER="$NEWUSER"
export NEWPASS="$NEWPASS"
export RI="$RI"
export X="$X"
export W="$W"
export P="$P"
export LO="$LO"
EOF
cat <<'EOF' > /mnt/o.sh
#!/bin/bash
source /v.sh
echo "> Entering chroot environtment."
echo "$H" > /etc/hostname
ln -sf /usr/share/zoneinfo/"$T" /etc/localtime
hwclock --systohc
[[ -z "$LO" ]] && eval "$LO" || echo "> Skipping swapfile creation."
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
[[ "$RI" == "5" ]] && echo "
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Adwaita" > /home/$NEWUSER/.config/gtk-3.0/settings.ini
[ -d "/minui" ] && cd /minui && sh x.sh && rm -rf /minui
eval "$P" && echo "> Installing DE Packages & Extras (If choosed)."
[[ ! "$RI" == "5" ]] && pacman -Sy --noconfirm pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh && eval "$X"
eval "$W"
rm -rf /v.sh
EOF
chmod +x /mnt/o.sh
}

#Used functions: R D T N E I S C L

while true; do
if [[ $EUID -ne 0 ]]; then # 1st stage, sudo
echo "! ERROR: Must run with sudo." && read -r -p "> Rerun with sudo? (y/n): " R
[[ ${R:-y} == [yY]* ]] && exec sudo "$0" "$@" || echo "> Exiting." && exit 1
else
break
fi && done

#1st stage, start
echo "> Shell Script (.sh) to install MinimalistUI."  && read -r -p "> Do you want to change console keyboard layout and font? (Modified settings will be saved to your new installation.) (y/n): " R
[[ ${R:-n} == [yY]* ]] && C || echo "> Not Changing Keyboard Layout (Default: US) and Console Font." #2nd stage, cfk

while true; do #3rd stage, networking
read -r -p "> Networking:
> '1' use ethernet,
> '2' use wifi (Heavily WIP and DIY.),
> '3' use wwan (WIP(???)),
> '0' to skip networking (Will install CLI-version of MinimalistUI (WIP)).
> answer: " RI
case $RI in
[Dd]) echo "> Debugging purpose only." && break;;
"") continue ;;
0) RI="5" && T && break
cat <<'EOF' > /etc/pacman.conf
[localrepos]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/pkg/
[extrarepos]
SigLevel = Optional TrustAll
Server = file:///minui/extrarepos
EOF
;;
1) I && if [[ "$?" == "1" ]]; then
continue
else
break
fi;;
3) I && if [[ "$?" == "1" ]]; then
continue
else
break
fi;;
2) while true; do
read -r -p "> iwctl:
> '1' see all options,
> '2' connect to network / wifis (wlan0),
> '3' connect to hidden network / wifis (wlan0),
> '4' see all connectable connections / wifis (wlan0),
> '5' enter your own command (input nothing to return here),
> 'r' return to earlier question.
> answer: " W
case $W in
1) iwctl help > iwctl.txt && echo "Use 'q' button to Quit." >> iwctl.txt && echo "> press 'y' to read iwctl.txt" && less iwctl.txt -F && rm -rf iwctl.txt && continue ;;
2) E && continue;;
3) LY="2" && E && continue;;
4) LY="1" && E && continue;;
5) read -r -p "> iwctl " R && iwctl $R > /dev/null 2>&1 && continue ;;
[Ff]) break 1 && continue;;
"") continue ;;
esac
I
if [[ "$?" == "1" ]]; then
continue
else
break 2
fi
done;;
esac && done


if [[ -z "$D" ]]; then #4th stage, partitioning
D
fi

echo "!!! Partitioning stage reached. You will be asked to Wipe your storage or no,"
echo "!!! '1' to wipe your storage (incl. partitions and datas), "
echo "!!! '0' to not (you can use your earlier partitioning scheme with this option)."
while true; do
read -r -p "!!! Do You Want To Wipe Out Your Storage To Continue? '1' for yes, '0' for no (Default): " R
if [[ ${R:-0} == 0* ]]; then
RA="A"
B="1"
break
else
while true; do
read -r -p "> Do you want to exit this script temporarily to move important data? '1' for yes, '0' to exit / skip (Default). " R
if [[ ${R:-0} == 0* ]]; then
break
else
S
fi
continue
done
while true; do
read -r -p "!!!!! Are You Sure That You Want To Wipe Out Your Disk? '1' for yes, '0' for no (Default): " R
if [[ ${R:-0} == 0* ]]; then
RA="A"
B="1"
break
else
echo "!!!!! Wiping '$D'"
sudo wipefs -a $D && break
fi
done
fi

while true; do
read -r -p "> In what size format would you like your new partitions be made? (Default=GiB)
> '1' use MiB,
> '2' use GiB,
> '3' use TiB.
> answer: " R
case $R in
1) P="${S}M" && B="MiB" && O="M" && break;;
3) P="${S}T" && B="TiB" && O="T" && break;;
*) P="${S}G" && B="GiB" && O="G" && break;;
"") continue;;
esac && done

while true; do
if [[ ! "$RA" == "A" ]]; then
export $B && R
elif [[ "$RA" == "8" ]]; then
if [[ -z "$ESPDIR" ]]; then
if [[ "$RR" == "1" ]]; then
while true; do
read -r -p "> Enter the full path for the ESP (e.g., /dev/sda1) ('1' to see all options): " ESPDIR
case $ESPDIR in
"") continue;;
1) lsblk && continue;;
*) break;;
esac && done
else
break && fi && fi && fi && done
if [ -z "$ROOTDIR" ]; then
while true; do
read -r -p "> Enter the full path for the ROOT partition (e.g., /dev/sda2): " ROOTDIR
case $ROOTDIR in
"") continue;;
1) lsblk && continue;;
*) break;;
esac && done && fi
read -r -p "> Are these paths correct? (y/n): " R
case $R in
[yY]*) break ;;
*) RA=""
continue ;; # Re-enter partition stage
esac;;
elif ! [[ "$RA" == "8" ]]; then
case $RA in
[Bb])  while true; do
read -r -p "> In what size format would you like your new partitions be made?
> '1' use MiB,
> '2' use GiB,
> '3' use TiB.
> answer: " R
case $R in
1) P="${S}M" && B="MiB" && O="M" && break;;
2) P="${S}G" && B="GiB" && O="G" && break;;
3) P="${S}T" && B="TiB" && O="T" && break;;
*) continue;;
esac && done;;
1) fdisk -h > fdisk.txt && echo "Use 'q' button to Quit." >> fdisk.txt && less fdisk.txt && rm -rf fdisk.txt && continue ;;
2) lsblk && continue ;;
3) while true; do
read -r -p "> GPT (1) or MBR (2) " R
case $R in
1) T="0FC63DAF-8483-4772-8E79-3D69D8477DE4" && L="gpt" && break;;
2) T="83" && L="dos" && break;;
*) continue;;
esac && done && while true; do
read -r -p "> How much (in $B) would you like to allocate to your new partition? " S
[[ -z "$S" ]] && continue
read -r -p "> What partition number would you give to your new partition? " N
[[ -z "$N" ]] && continue
done
export D L O P T N
sudo sfdisk $D --append --force --quiet <<EOF
label: $L
unit: $O
$N : size=$S, type=$T, name="DIR"
EOF
DD=$(N "$D" "$N")
while true; do
read -r -p "> Choose the format for your new partition
> '1' F2FS, recomended for ssds... supposedly,
> '2' BTRFS, modern, feature-rich...,
> '3' XFS, recomended for big files... supposedly,
> '4' EXT4, classic...
> '5' FAT12.
> '6' FAT16.
> '7' FAT32
> answer: " F
case $F in
1) FM="mkfs.f2fs" && break;;
2) FM="mkfs.btrfs" && break;;
3) FM="mkfs.xfs" && break;;
4) FM="mkfs.ext4" && break;;
5) FM="mkfs.fat -F 12" && break;;
6) FM="mkfs.fat -F 16" && break;;
7) FM="mkfs.fat -F 32" && break;;
*) continue ;;
esac && done
echo "> Creating partition at: $DD" && $FM $DD;;
4) while true; do
read -r -p "> How much (in $B) would you like to allocate to your new partition? " S
[[ -z "$S" ]] && continue
done
export D O P
sudo sfdisk $D --append --force --quiet <<EOF
label: gpt
unit: $O
1 : size=$P, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="ESPDIR"
EOF
ESPDIR=$(N "$D" "1")
while true; do
echo "$Q Choose the fat size for ESP (12, 16, and 32 (32 is Recomended)) and choose the partition"
read -r -p "$Q Which fat format would you like to use? (Default=fat32)
> '1' FAT12.
> '2' FAT16.
> '3' FAT32
> answer: " R
case $R in
1) FM="mkfs.fat -F 12" && break;;
2) FM="mkfs.fat -F 16" && break;;
3 | "") FM="mkfs.fat -F 32" && break;;
*) continue;;
esac && done
echo "> Creating ESP at: $ESPDIR"
$FM $ESPDIR;;
5) while true; do
read -r -p "> GPT (1) or MBR (2) " RR
case $RR in
1) T="0FC63DAF-8483-4772-8E79-3D69D8477DE4" && L="gpt" && N="2" && break;;
2) T="83" && L="dos" && N="1" && break;;
*) continue;;
esac && done
while true; do
read -r -p "> How much (in $B) would you like to allocate to your new partition? " S
[[ -z "$S" ]] && continue
done
export D L O P T N
sudo sfdisk $D --append --force --quiet <<EOF
label: $L
unit: $O
$N : size=$P, type=$T, name="ROOTDIR"
EOF
ROOTDIR=$(N "$D" "$N")
while true; do
read -r -p "> Choose the format for Root Partition (Default=F2FS)
> '1' F2FS, recomended for ssds... supposedly,
> '2' BTRFS, modern, feature-rich...,
> '3' XFS, recomended for big files... supposedly,
> '4' EXT4, classic...
> answer: " FS
case $FS in
1 | "") FM="mkfs.f2fs" && break;;
2) FM="mkfs.btrfs -f" && break;;
3) FM="mkfs.xfs" && break;;
4) FM="mkfs.ext4" && break;;
*) continue ;;
esac && done && $FM $ROOTDIR;;
6) if [[ "$FS" == "2" || "$F" == "2" ]]; then
mount -o rw $ROOTDIR /mnt && echo "> Mounting Root directory temporarily." && while true; do
echo "#!/bin/bash" > /x.sh
read -r -p "> What type of subvolume would you like to create?
> '1' to create system subvol,
> '2' to create userdata subvol,
> '3' to create log subvol,
> '4' to create swap,
> '0' to exit,
> '(enter your own)' to create your own subvol.
> answer: " R
case $R in
1) btrfs subvolume create /mnt/@ && echo "umount /mnt && mount -o subvol=@,compress=zstd $ROOTDIR /mnt" >> /x.sh
continue;;
2) btrfs subvolume create /mnt/@home && echo "mkdir -p /mnt/home && umount /mnt && mount -o subvol=@home,compress=zstd $ROOTDIR/home /mnt/home" >> /x.sh && continue;;
3) btrfs subvolume create /mnt/@log && echo "mkdir -p /mnt/log && umount /mnt && mount -o subvol=@log,compress=zstd $ROOTDIR/log /mnt/log" >> /x.sh && continue;;
4) btrfs subvolume create /mnt/swapfile && truncate -s 0 /mnt/swapfile && chattr +C /mnt/swapfile && btrfs property set /mnt/swapfile compression none && LO="" && continue;;
0) chmod +x /x.sh && sh /x.sh && rm -rf /x.sh && break;;
*) btrfs subvolume create /mnt@"${R}" && echo 'mkdir -p /mnt/"$R" && umount /mnt && mount -o subvol=@"${R}",compress=zstd $ROOTDIR/"$R" /mnt/"$R"' >> /x.sh && continue;;
"") continue;;
esac && break && done
fi && [[ ! "$FS" == "2" || "$F" == "2" ]] echo "!! We spotted that you didnt use 'BTRFS' for your Root Partition, exiting option." && break 1 && continue;;
7) sudo cfdisk && continue;;
[A])while true; do
read -r -p "> Do You Wanna Use Your Earlier Partition Setup? '1' for yes, '0' for no: " R
case $R in
1) RA="8" && break 1 && continue;;
0) RA="" && break 1 && continue;;
"") continue;;
esac && done;;
*) RA="" && continue;;
esac && fi && done
#5th stage, 1st install stage
read -r -p "> What username would you like to have? : " NEWUSER
read -r -p "> What password would you like to have for your new user? : " NEWPASS
read -r -p "> What hostname would you like to have? : " H
while true; do
read -r -p "> Which bootloader would you like to use? '1' for grub (Universal), '0' for systemd (Default, GPT/EFI only)" V
if [[ ${V:-0} == 0* ]]; then
read -r -d '' P <<'EOF'
echo "bootctl install" >> o.sh
while true; do
read -r -p '> Do you want to be able to modify boot entries when bootup? '1' for yes (default (recomended for personal use)), '0' for no (more secure (recomended for mass use))' EW
case $EW in
0) RT="" && break;;
*) RT="1" && break;;
"") continue;;
esac && done && break
EOF
break && fi && done
while true; do
if [[ ${V:-0} == 0* && ! -z "$ESPDIR" ]]; then
read -r -d '' P <<'EOF'
P="grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB && grub-mkconfig -o /boot/grub/grub.cfg"
EOF
F="" && break
else
read -r -d '' P <<'EOF'
P="grub-install --target=i386-pc $D && grub-mkconfig -o /boot/grub/grub.cfg"
EOF
F="grub" && break
fi && done
mkdir -p /mnt && mount $ROOTDIR /mnt && ROOT_PART=$(findmnt -n -o SOURCE /mnt) && ROOT_UUID=$(blkid -s UUID -o value $ROOT_PART)
[[ ! -z "$ESPDIR" ]] && mkdir -p /mnt/boot && mount $ESPDIR /mnt/boot
[[ ! -f "/mnt/swapfile" ]] && while true; do
read -r -p "> Do you want to create a swapfile (Like a swap partition but is deleteable, simple and didnt need new partition)? (y/n)" LO
case $LO in
[Yy]*) read -r -d '' LO <<'EOF'
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && echo "/swapfile none swap defaults 0 0" >> /etc/fstab
EOF
break;;
[nN]*) break;;
"") continue;;
esac && done && fi
cp -r /minui /mnt/minui && cp -r /var/lib/iwd/ /mnt/var/lib/iwd/ && cp -r /etc/NetworkManager/system-connections/ /mnt/etc/NetworkManager/system-connections/ && cp -r /etc/vconsole.conf /mnt/etc/vconsole.conf && cp -r /etc/locale.conf /mnt/etc/locale.conf
#5th Stage, 2nd Install Stage
[[ ! "$V" == "1" ]] && echo "default minui.conf
timeout 4
console-mode max" > /mnt/boot/loader/loader.conf | echo "
title MinimalistUI
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options nvme_load=YES nowatchdog root=UUID=$ROOT_UUID rw loglevel=3 swapfile=/swapfile" > /mnt/boot/loader/entries/minui.conf | echo "
title MinimalistUI (CLI)
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options nvme_load=YES nowatchdog root=UUID=$ROOT_UUID rw loglevel=3 swapfile=/swapfile systemd.unit=multi-user.target" > /mnt/boot/loader/entries/minuicli.conf
[[ "$RT" == "" ]] && echo "editor no" >> /mnt/boot/loader/loader.conf || echo "editor yes" >> /mnt/boot/loader/loader.conf
while true; do
read -r -d '' X << 'EOF'
[[ ! "$RI" == "5" ]] && pacman -S --no-confirm kate gparted lutris steam mangohud firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman network-manager-applet udisks2 gvfs kitty fastfetch cpufetch htop papirus-icon-theme flatpak mpd materia-gtk-theme mpv bash-completion kvantum labwc swaybg mako waybar fuzzel grim slurp wl-clipboard kanshi playerctl
[[ "$RI" == "5" ]] && paccache -rk1 -c /minui/extrarepos/
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
read -r -d '' W << 'EOF'
sudo -u "$NEWUSER" flatpak --noninteractive --user -y install sober zoom zapzap telegram
EOF
read -r -p "> Would you like to install extra packages (you can go to https://github.com/xv7ranker/minimalistui to see every packages (including extras))?
> '1' install all extra packages (Recomended, tho optional (Incl. Support for wayland)),
> '2' install extra pacman packages (Incl. Support for wayland),
> '3' install extra flatpak packages,
> '4' see all exrta packages,
> '0' do not install extra packages.
> answer: " RB
case $RB in
1) break;;
2) W="echo "> skipping installing extra flatpak packages."" && break;;
3) X="echo "> skipping installing extra pacman packages."" && break;;
4) echo "$X" && echo "$W" && continue;;
0) X="echo "> skipping installing extra pacman packages."" && "echo "> skipping installing extra flatpak packages."" && break;;
*) continue ;;
esac && done
VENDORID=$(grep 'vendor_id' /proc/cpuinfo | head -n 1 | awk '{print $NF}')
[[ "$VENDORID" == "GenuineIntel" ]] && C="intel-ucode" && echo "> CPU is Intel, installing $C"
[[ "$VENDORID" == "AuthenticAMD" ]] && C="amd-ucode" && echo "> CPU is AMD, installing $C"
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
1) G="xf86-video-amdgpu vulkan-radeon" && break;;
2) G="xf86-video-ati" && break;;
3) G="xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver" && break;;
4) G="nvidia-dkms nvidia-settings nvidia-utils linux-zen-headers" && break;;
5) G="xf86-video-nouveau" && break;;
6) G="xf86-video-vesa" && break;;
7) G="xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon linux-zen-headers" && C="intel-ucode amd-ucode" && break;;
*) continue;;
esac && done && pacstrap -K /mnt base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva mesa-vdpau libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs fzf bat zoxide lf thefuck ntfs-3g unzip p7zip unrar gufw ufw neovim squashfs-tools sudo git $G $C $F && genfstab -U /mnt >> /mnt/etc/fstab && L && arch-chroot /mnt <<EOF
sh o.sh && rm -rf o.sh
EOF
if [[ "$RI" == "5" ]]; then
mkdir -p /mnt/var/lib/pacman/sync && cp /var/lib/pacman/sync/ /mnt/var/lib/pacman/sync/
cat <<EOF >> /etc/pacman.conf
[local]
SigLevel = Optional TrustAll
Server = file:///minui/extrarepos
EOF
pacstrap -c /mnt base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva mesa-vdpau libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs fzf bat zoxide lf thefuck ntfs-3g unzip p7zip unrar gufw ufw neovim squashfs-tools sudo git pasystray thunar pipewire-alsa pipewire-pulse pipewire-jack pipewire ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji firefox pavucontrol firefox-i18n-en-us xorg-xinit tint2 nwg-look rofi dunst feh $G $C $F
eval "$X" && genfstab -u /mnt >> /mnt/etc/fstab && L && arch-chroot /mnt <<EOF
sh o.sh && rm -rf o.sh
EOF
fi
while true; do
echo "!!!!! MinimalistUI finished installing, enter '1' to exit," && read -r -p "!!!!! Make sure to unplug the installation media too after this." R
[[ "$R" =~ ^[1]$ ]] && umount -R /mnt && exit && break || continue
fi && done && reboot
