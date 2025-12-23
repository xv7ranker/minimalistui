#!/bin/bash
Q="[root@archiso /]# "
while true; do
if [[ $EUID -ne 0 ]]; then # 1st stage, sudo
    echo "$Q ERROR: Must run with sudo."
    read -r -p "$Q Rerun with sudo? (y/n): " R
    case $R in
    [yY]) exec sudo "$0" "$@" ;;
    "") continue ;;
    *) echo "$Q Exiting."
       exit 1 ;;
    esac
else
    break
fi
done
echo "$Q Shell Script (.sh) to install MinimalistUI."
read -r -p "$Q Do you want to change console keyboard layout and font? (Modified Language & Font Settings will be saved and copied into your new installation later.) (y/n): " R # 2nd stage, console font & keyboard layout settings
while true; do
case $R in
[yY]) read -r -p "$Q Change your keyboard layout to:
- '0' to skip,
- '1' to see all options,
- 'us' to set keyboard layout to US (Default),
- 'de-latin1' to set keyboard layout to German.
-  answer: " K
    case $K in
    0) ;;
    1) localectl list-keymaps > keymaps.txt
        echo "Use 'q' button to Quit." >> keymaps.txt
        less keymaps.txt
        continue ;;
    "") continue ;;
    *) if localectl list-keymaps | grep -q "^$K$"; then
        loadkeys $K
        rm -rf keymaps.txt
        break
        else
        echo "$Q Keyboard layout "$K" not found, try again."
        continue ;;
    esac
    read -r -p "$Q Change your console font to:
    - '0' skip,
    - '1' see all options,
    - 'ter-132b' for HiDPI screens (arch installation guide recomendation).
    -  answer: " C
        case $C in
        0) break ;;
        1) ls /usr/share/kbd/consolefonts > fonts.txt
            echo "When changing font, add the format of the font you want to change to, like if you want to change to
            iso01.08, you should write iso01.08.gz." >> fonts.txt
            echo "$Q Ignore files starting with 'README.'."
            echo "Use 'q' button to Quit." >> fonts.txt
            less fonts.txt
            continue ;;
        *) FONT_BASE_PATH="/usr/share/kbd/consolefonts/$C"
            if [ -f "$FONT_BASE_PATH" ] || [ -f "$FONT_BASE_PATH.psf.gz" ] || [ -f "$FONT_BASE_PATH.psf" ]; then
                setfont $C
                rm -rf fonts.txt
                break
            else
                echo "$Q ERROR: Console font '$C' not found, try again."
                continue
            fi ;;
        "") continue ;;
        esac ;;
[nN]) echo "$Q Not Changing Keyboard Layout (Default: US) and Console Font."
    break ;;
"") continue ;;
esac
done
while true; do # 3rd stage, networking settings
    read -r -p "$Q Networking:
    - '1' use ethernet,
    - '2' use wifi (Heavily WIP and DIY.),
    - '3' use wwan (WIP(???)).
    -  answer: " R
case $R in
    "") continue ;;
    [dD]) echo "$Q Skipping connection."
        echo "$Q Debugging Purpose Only."
        break ;;
    1) echo "$Q Trying to ping ping.archlinux.org"
        ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$Q ping ping.archlinux.org succesfull, continuing."
            break
        else
            echo "$Q ping ping.archlinux.org failed, check ethernet cable / internet status before re-trying."
            continue
        fi ;;
    3) echo "$Q Trying to ping ping.archlinux.org"
        ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$Q ping ping.archlinux.org succesfull, continuing."
            break
        else
            echo "$Q ping ping.archlinux.org failed, check cellular data amount left / local area internet status before re-trying."
            continue
        fi ;;
    2) read -r -p "$Q iwctl:
        - '1' see all options,
        - '2' connect to network / wifis (wlan0),
        - '3' connect to hidden network / wifis (wlan0),
        - '4' see all connectable connections / wifis (wlan0),
        - '5' enter your own command (input nothing to return here),
        - 'f' finish (Used after preparing Wifi.).
        -  answer: " W
        case $W in
            1) iwctl help > iwctl.txt
                echo "Use 'q' button to Quit." >> iwctl.txt
                echo "[$P@$Q $U]# press 'y' to read iwctl.txt"
                less iwctl.txt -F
                rm -rf iwctl.txt
                continue ;;
            2) read -r -p "$Q usage: iwctl station wlan0 connect <network name> <security protocol>
                iwctl station wlan0 connect " R
                iwctl station wlan0 connect $R
                break ;;
            3) read -r -p "$Q usage: iwctl station wlan0 connect-hidden <hidden network name>
                iwctl station wlan0 connect-hidden " R
                iwctl station wlan0 connect-hidden $R
                break ;;
            4) iwctl station wlan0 get-networks > iwctl.txt
                echo "Use 'q' button to Quit." >> iwctl.txt
                echo "$Q press 'y' to read iwctl.txt"
                less iwctl.txt -F
                rm -rf iwctl.txt
                break ;;
            5) read -r -p "$Q iwctl " R
                iwctl $R
                continue ;;
            "") continue ;;
            fF) break ;;
        esac
            echo "$Q Trying to ping ping.archlinux.org"
            ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$Q ping ping.archlinux.org succesfull, continuing."
            break
        else
        echo "$Q ping ping.archlinux.org failed, check wifi connection / local area internet status before re-trying."
        continue
        fi ;;
esac
done
while true; do # timezone setting stage
read -r -p "$Q '1' to list timezones, and type the timezones to set the timezone (Area/Location (e.g. Asia/Jakarta)): " T
    case $T in
    1) timedatectl list-timezones > timezones.txt
        echo "Use 'q' button to Quit." >> timezones.txt
        less timezones.txt
        rm -rf timezones.txt
        continue ;;
    *) timedatectl set-timezones $T
        break ;;
    "") continue ;;
    esac
echo "$Q Current date & time:"
timedatectl
done
get_partition_path() {
    local dev=$1
    local num=$2
    if [[ $dev == *[0-9] ]]; then
        echo "${dev}p${num}"
    else
        echo "${dev}${num}"
    fi
}
# Usage:
# RR=$(get_partition_path "$D" "$N")
while true; do # partition creation stage
read -r -p "$Q fdisk:
    - '1' see all options,
    - '2' list partitions and disks in a .txt file,
    - '2b' use 'blkid' to list partitions and disks into a .txt file,
    - '2l' use 'lsblk' to list partitions and disks into a .txt file,
    - '3' create Empty Partition,
    - '4' create ESP (GPT, part. no. 1),
    - '5' create Root Partition (GPT/MBR, part. no. (1 for mbr, 2 for gpt)),
    - '6' create empty partition (DIY) (input nothing to return here) (WIP),
    - '7' finish (use after finished creating partitions).
    - notes: create ESP first before creating Root partition for GPT environtment.
    - notes: for MBR users, create root partition straight away.
    -  answer: " R
    case $R in
    1) fdisk -h > fdisk.txt
        echo "Use 'q' button to Quit." >> fdisk.txt
        less fdisk.txt
        rm -rf fdisk.txt
        continue ;;
    2) fdisk -l > fdisk.txt
        echo "Use 'q' button to Quit." >> fdisk.txt
        less fdisk.txt
        rm -rf fdisk.txt
        continue ;;
    [2][bB]) blkid > blkid.txt
            echo "Use 'q' button to Quit." >> blkid.txt
            less blkid.txt
            rm -rf blkid.txt
            continue ;;
    [2][lL]) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue ;;
    3) if [[ -z "$D" ]]; then
        while true; do
        read -r -p "$Q Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmexn1' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " D
        case $D in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue;;
        *) break;;
        "") continue;;
        esac
        done
        fi
        while true; do
        read -r -p "$Q In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $O in
        1) P="${S}M"
            B="MiB"
            O="M"
            break;;
        2) P="${S}G"
            B="GiB"
            O="G"
            break;;
        3) P="${S}T"
            B="TiB"
            O="T"
            break;;
        *) continue;;
        esac
        done
        while true; do
        read -r -p "$Q GPT (1) or MBR (2)" R
        case $R in
        1) T="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
            L="gpt"
            break;;
        2) T="83"
            L="dos"
            break;;
        *) continue;;
        esac
        done
        read -r -p "$Q How much (in $B) would you like to allocate to your new partition?" S
        read -r -p "$Q What partition number would you give to your new partition?" N
        sudo sfdisk $D --wipe-table --force --quiet <<EOF
        label: $L
        unit: $O
        $N : size=$S, type=$T, name="DIR"
EOF
        DD=$(get_partition_path "$D" "$N")
        while true; do
        read -r -p "$Q Choose the format for your new partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - '5' for fat12.
        - '6' for fat16.
        - '7' for fat32
        - answer: " R
        case $R in
        1) FM="mkfs.f2fs"
            break;;
        2) FM="mkfs.btrfs"
            break;;
        3) FM="mkfs.xfs"
            break;;
        4) FM="mkfs.ext4"
            break;;
        5) FM="mkfs.fat -F 12"
            break;;
        6) FM="mkfs.fat -F 16"
            break;;
        7) FM="mkfs.fat -F 32"
            break;;
        *) continue ;;
        esac
        echo "$Q Creating partition at: $DD"
        $FM $DD ;;
    4) if [[ -z "$D" ]]; then
        while true; do
        read -r -p "$Q Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmex' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " D
        case $D in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue;;
        *) break;;
        "") continue;;
        esac
        done
        fi
        while true; do
        read -r -p "$Q In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $O in
        1) P="${S}M"
            B="MiB"
            O="M"
            break;;
        2) P="${S}G"
            B="GiB"
            O="G"
            break;;
        3) P="${S}T"
            B="TiB"
            O="T"
            break;;
        *) continue;;
        esac
        done
        read -r -p "$Q How much (in $B) would you like to allocate to your new partition?" S
        sudo sfdisk $D --wipe-table --force --quiet <<EOF
        label: gpt
        unit: $O
        1 : size=$P, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="ESPDIR"
EOF
        ESPDIR=$(get_partition_path "$D" "1")
        while true; do
        echo "$Q Choose the fat size for ESP (12, 16, and 32 (32 is Recomended)) and choose the partition"
        read -r -p "$Q Which fat format would you like to use?
        - '1' for fat12.
        - '2' for fat16.
        - '3' for fat32
        - answer: " R
        case $R in
        1) FM="mkfs.fat -F 12"
            break;;
        2) FM="mkfs.fat -F 16"
            break;;
        3) FM="mkfs.fat -F 32"
            break;;
        *) continue
        esac
        done
        echo "$Q Creating ESP at: $ESPDIR"
        $FM $ESPDIR
        ;;
    5) if [[ -z "$D" ]]; then
        while true; do
        read -r -p "$Q Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmex' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " D
        case $D in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue;;
        *) break;;
        "") continue;;
        esac
        done
        fi
        while true; do
        read -r -p "$Q In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $O in
        1) P="${S}M"
            B="MiB"
            O="M"
            break;;
        2) P="${S}G"
            B="GiB"
            O="G"
            break;;
        3) P="${S}T"
            B="TiB"
            O="T"
            break;;
        *) continue;;
        esac
        done
        while true; do
        read -r -p "$Q GPT (1) or MBR (2)" R
        case $R in
        1) T="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
            L="gpt"
            break;;
        2) T="83"
            L="dos"
            break;;
        *) continue;;
        esac
        read -r -p "$Q How much (in $B) would you like to allocate to your new partition?" S
        sudo sfdisk $D --wipe-table --force --quiet <<EOF
        label: $L
        unit: $O
        2 : size=$P, type=$T, name="ROOTDIR"
EOF
        if [[ -z "$ESPDIR" ]]
            N="1"
        else
            N="2"
        fi
        ROOTDIR=$(get_partition_path "$D" "$N")
        while true; do
        read -r -p "$Q Choose the format for Root Partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - answer: " R
        case $R in
        1) FM="mkfs.f2fs"
            break;;
        2) FM="mkfs.btrfs"
            break;;
        3) FM="mkfs.xfs"
            break;;
        4) FM="mkfs.ext4"
            break;;
        *) continue ;;
        esac
        done
        $FM $ROOTDIR ;;
    6) read -r -p "$Q usage: fdisk <device>
            fdisk " R
            case $R in
            "") continue ;;
            *) fdisk $R
                continue ;;
            esac ;;
    7) if [ -z "$ESPDIR" ]; then
            read -r -p "$Q Enter the full path for the ESP/BOOT partition (e.g., /dev/sda1): " ESPDIR
        fi
        if [ -z "$ROOTDIR" ]; then
            read -r -p "$Q Enter the full path for the ROOT partition (e.g., /dev/sda2): " ROOTDIR
        fi
        read -r -p "$Q Are these paths correct? (y/n): " R
            case $R in
            [yY]*) break ;;
            *) continue ;; # Re-enter partition stage
            esac ;;
    *) continue;;
    esac
done
read -r -p "$Q What username would you like to have? : " NEWUSER
read -r -p "$Q What hostname would you like to have? : " H
    while true; do
    read -r -p "'1' for grub (Universal), '0' for systemd (Default, GPT/EFI only)" V
    case $V in
    1) if ! [[ -z "$ESPDIR" ]]; then
            P="grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB && grub-mkconfig -o /boot/grub/grub.cfg"
            F=""
        else
            P="grub-install --target=i386-pc $D && grub-mkconfig -o /boot/grub/grub.cfg"
            F="grub"
        fi

        break;;
    *) P="bootctl install"
        while true; do
        read -r -p "Do you want to be able to modify boot entries when bootup? '1' for yes (default (recomended for personal use)), '0' for no (more secure (recomended for mass use))" EW
        case $EW in
        0) RT=""
            break;;
        *) RT="1"
            break;;
        "") continue;;
        esac
        done
        break;;
    "") continue;;
    esac
    done
    while true; do # alot of install stuffs
    X="pacman -S --no-confirm kate gparted xarchiver xfce4-screenshooter xfce4-mount-plugin xfce4-mpc-plugin xfce4-clipman-plugin lutris steam mangohud xfce4-whiskermenu-plugin firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso"
    W="sudo -u "$NEWUSER" flatpak --noninteractive --user -y install sober zoom zapzap telegram"
    read -r -p "$Q Would you like to install extra packages (you can go to https://github.com/xv7ranker/minimalistui to see every packages (including extras))?
    - '1' install all extra packages,
    - '2' install extra pacman packages,
    - '3' install extra flatpak packages,
    - '0' do not install extra packages.
    - answer: " R
    case $R in
    1) break;;
    2) W="echo "$Q skipping installing extra flatpak packages.""
        break;;
    3) X="echo "$Q skipping installing extra pacman packages.""
        break;;
    0) X="echo "$Q skipping installing extra pacman packages.""
        W="echo "$Q skipping installing extra flatpak packages.""
        break;;
    *) continue ;;
    esac
    done
    VENDORID=$(grep 'vendor_id' /proc/cpuinfo | head -n 1 | awk '{print $NF}')
    if [[ "$VENDORID" == "GenuineIntel" ]]; then
        C="intel-ucode"
        echo "$Q CPU is Intel, installing $C"
    elif [[ "$VENDORID" == "AuthenticAMD" ]]; then
        C="amd-ucode"
        echo "$Q CPU is AMD, installing $C"
    fi
    while true; do
    read -r -p "$Q Which GPU driver would you like to install?
    - '1' to install AMD GPU Driver (Modern (xf86-video-amdgpu)) + Vulkan (vulkan-radeon) + Mesa (Depend.),
    - '2' to install AMD GPU Driver (Old (xf86-video-ati)) + Mesa (Default),
    - '3' to install Intel GPU Driver (xf86-video-intel) + Vulkan (vulkan-intel) + Mesa (Depend.) + Media Driver (Extra),
          (Compatible w/ older non-vulkan igps),
    - '4' to install NVIDIA GPU Driver (Proprietary (nvidia-dkms + nvidia-settings)) + Vulkan (Incl.) Mesa (Default),
    - '5' to install NVIDIA GPU Driver (Open Source (xf86-video-nouveau)) + Mesa (Default) (No Vulkan (???)),
    - '6' to install Generic Fallback Driver (NOT RECOMENDED FOR NEWER SYSTEMS, USE AS FALLBACK ONLY) (xf86-video-vesa) + Mesa (Default),
    - '7' to install ALL GPU Drivers (Incl. Mesa & Media Drivers) & CPU Microcodes (Overrides) (Commonly heavier).
    - answer: " R
    if [ -n "$ESPDIR" ] && [ -n "$ROOTDIR" ] && [ -n "$NEWUSER" ] && [ -n "$R" ]; then
        ROOT_UUID=$(blkid -s UUID -o value "$ROOTDIR")
        if [ -z "$ROOT_UUID" ]; then
            echo "$Q ERROR: Could not find UUID for Root Directory ($ROOTDIR). Check disk path."
            continue
        fi
        break
    else
        continue
    fi
    done
    case $R in
    1) G="xf86-video-amdgpu vulkan-radeon" ;;
    2) G="xf86-video-ati" ;;
    3) G="xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver" ;;
    4) G="nvidia-dkms nvidia-settings nvidia-utils linux-zen-headers" ;;
    5) G="xf86-video-nouveau" ;;
    6) G="xf86-video-vesa" ;;
    7) G="xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon linux-zen-headers"
        C="intel-ucode amd-ucode" ;;
    *) continue;;
    esac
    mkdir -p /mnt
    mount $ROOTDIR /mnt
    if ! [[ -z "$ESPDIR" ]]; then
        mkdir -p /mnt/boot
        mount $ESPDIR /mnt/boot
    fi
    if ! [[ "$V" == "1" ]]; then
        echo "default minui.conf
        timeout 4
        console-mode max" > /mnt/boot/loader/loader.conf
        if [[ "$RT" == "" ]]; then
            echo "editor no" >> /mnt/boot/loader/loader.conf
        else
            echo "editor yes" >> /mnt/boot/loader/loader.conf
    if

    pacstrap -K /mnt base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva mesa-vdpau libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs fzf bat zoxide lf thefuck ntfs-3g unzip p7zip unrar gufw ufw neovim squashfs-tools $G $C $F
    genfstab -U /mnt >> /mnt/etc/fstab
    mv /minui /mnt/minui
    cp -r /var/lib/iwd/ /mnt/var/lib/iwd/
    cp -r /etc/NetworkManager/system-connections/ /mnt/etc/NetworkManager/system-connections/
    cp -r /etc/vconsole.conf /mnt/etc/vconsole.conf
    cp -r /etc/locale.conf /mnt/etc/locale.conf
    arch-chroot /mnt <<EOF
    Q=\"[root@$H /]"
    echo "$Q Entering chroot environtment."
    echo "$H" > /etc/hostname
    dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
    if [ "$(stat -f -c %T /)" == "btrfs" ]; then
        truncate -s 0 /swapfile
        chattr +C /swapfile
        fallocate -l 8G /swapfile
    fi
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap defaults 0 0" >> /etc/fstab
    ln -sf /usr/share/zoneinfo/"$T" /etc/localtime
    hwclock --systohc
    locale-gen
    echo "$Q Creating account."
    useradd -m -G wheel,audio,video,storage,power -s /bin/bash "$NEWUSER"
    echo "$Q You can modify root account password using command "passwd" while being root user or "sudo passwd" if you are using user account and you didnt know what your root account password is."
    echo "$Q Set your new user password."
    passwd "$NEWUSER"
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/99_wheel_config
    echo 'fastfetch' >> /home/"$NEWUSER"/.bashrc
    echo 'cpufetch' >> /home/"$NEWUSER"/.bashrc
    mkdir /home/"$NEWUSER"/media
    ln -sf /run/"$NEWUSER" /home/"$NEWUSER"/media
    chown -R "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"
    chmod +x /home/"$NEWUSER"/.xinitrc
    chmod +x /home/"$NEWUSER"/.bash_profile
    $P
    echo "$Q Installing DE Packages & Some Extras."
    pacman -S --noconfirm xfce4 volctl pasystray thunar flatpak kvantum mpv tint2 papirus-icon-theme xfce4-battery-plugin xfce4-notifyd xfce4-pulseaudio-plugin fastfetch cpufetch htop pipewire-alsa pipewire-pulse pipewire-jack pipewire bash-completion mpd kitty ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji materia-gtk-theme firefox udisks2 gvfs network-manager-applet pavucontrol firefox-i18n-en-us git thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman
    $X
    $W
    sudo -u "$NEWUSER" git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git)
    cd yay
    sudo -u "$NEWUSER" makepkg -si
    cd /minui
    sh x.sh
    rm -rf /minui
    sudo -u "$NEWUSER" xfconf-query -c xsettings -p /Net/ThemeName -s "Materia-dark-compact" --create -t string
    sudo -u "$NEWUSER" xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" --create -t string
    KVANTUM_CONFIG_PATH="/home/$NEWUSER/.config/Kvantum"
    KVANTUM_CONFIG_FILE="$KVANTUM_CONFIG_PATH/kvantum.kvconfig"
    mkdir -p "$KVANTUM_CONFIG_PATH"
    echo -e "[General]\ntheme=Breeze-Dark" > "$KVANTUM_CONFIG_FILE"
    chown -R "$NEWUSER":"$NEWUSER" "$KVANTUM_CONFIG_PATH"
    echo "export QT_QPA_PLATFORMTHEME=kvantum" | sudo -u "$NEWUSER" tee -a /home/"$NEWUSER"/.profile > /dev/null
    sudo -u "$NEWUSER" xfconf-query -c xsettings -p /Gtk/FontName -s "Noto Sans Regular 10" --create -t string
    sudo -u "$NEWUSER" xfconf-query -c xfce4-panel -p /panels/panel-1/hidden -s true --create -t bool
    systemctl enable NetworkManager.service
    systemctl enable fstrim.timer
    systemctl enable systemd-timesyncd.service
    systemctl --user enable pipewire
    systemctl --user enable pipewire-session-manager.service
    systemctl enable ufw.service
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing
EOF
    while true; do
    read -r -p "$Q MinimalistUI finished installing, enter '1' to exit (make sure to unplug the installation media too after this)" R
    if [[ "$R" =~ ^[1]$ ]]; then
    umount -R /mnt
    exit
    break
    else
    continue
    fi
    done
    reboot
