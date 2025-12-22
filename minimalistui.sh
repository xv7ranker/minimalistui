#!/bin/bash
T=$(pwd)
P=$(whoami)
U=$(basename "$T")
Q=$(cat /etc/hostname)
while true; do
if [[ $EUID -ne 0 ]]; then # 1st stage, sudo
    echo "[$P@$Q $U]$ ERROR: Must run with sudo."
    read -r -p "[$P@$Q $U]$ Rerun with sudo? (y/n): " R
    case $R in
    [yY]) exec sudo "$0" "$@" ;;
    "") continue ;;
    *) echo "[$P@$Q $U]#$ Exiting."
       exit 1 ;;
    esac
else
    break
fi
done


echo "[$P@$Q $U]# Shell Script (.sh) to install MinimalistUI."
read -r -p "[$P@$Q $U]# Do you want to change console keyboard layout and font? (y/n): " R # 2nd stage, console font & keyboard layout settings
while true; do
case $R in
[yY]) read -r -p "[$P@$Q $U]# Change your keyboard layout to:
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
        echo "[$P@$Q $U]# Keyboard layout "$K" not found, try again."
        continue ;;
    esac
    read -r -p "[$P@$Q $U]# Change your console font to:
    - '0' skip,
    - '1' see all options,
    - 'ter-132b' for HiDPI screens (arch installation guide recomendation).
    -  answer: " C
        case $C in
        0) break ;;
        1) ls /usr/share/kbd/consolefonts > fonts.txt
            echo "When changing font, add the format of the font you want to change to, like if you want to change to
            iso01.08, you should write iso01.08.gz." >> fonts.txt
            echo "[$P@$Q $U]# Ignore files starting with 'README.'."
            echo "Use 'q' button to Quit." >> fonts.txt
            less fonts.txt
            continue ;;
        *) FONT_BASE_PATH="/usr/share/kbd/consolefonts/$C"
            if [ -f "$FONT_BASE_PATH" ] || [ -f "$FONT_BASE_PATH.psf.gz" ] || [ -f "$FONT_BASE_PATH.psf" ]; then
                setfont $C
                rm -rf fonts.txt
                break
            else
                echo "[$P@$Q $U]# ERROR: Console font '$C' not found, try again."
                continue
            fi ;;
        "") continue ;;
        esac ;;
[nN]) echo "[$P@$Q $U]# Not Changing Keyboard Layout (Default: US) and Console Font."
    break ;;
"") continue ;;
esac
done


while true; do # 3rd stage, networking settings
    read -r -p "[$P@$Q $U]# Networking:
    - '1' use ethernet,
    - '2' use wifi (Heavily WIP.),
    - '3' use wwan (WIP(???)).
    -  answer: " R
case $R in
    "") continue ;;
    [dD]) echo "[$P@$Q $U]# Skipping connection."
        echo "[$P@$Q $U]# Debugging Purpose Only."
        break ;;
    1) echo "[$P@$Q $U]# Trying to ping ping.archlinux.org"
        ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "[$P@$Q $U]# ping ping.archlinux.org succesfull, continuing."
            break
        else
            echo "[$P@$Q $U]# ping ping.archlinux.org failed, check ethernet cable / internet status before re-trying."
            continue
        fi ;;
    3) echo "[$P@$Q $U]# Trying to ping ping.archlinux.org"
        ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "[$P@$Q $U]# ping ping.archlinux.org succesfull, continuing."
            break
        else
            echo "[$P@$Q $U]# ping ping.archlinux.org failed, check cellular data amount left / local area internet status before re-trying."
            continue
        fi ;;
    2) read -r -p "[$P@$Q $U]# iwctl:
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
            2) read -r -p "usage: iwctl station wlan0 connect <network name> <security protocol>
                iwctl station wlan0 connect " R
                iwctl station wlan0 connect $R
                break ;;
            3) read -r -p "usage: iwctl station wlan0 connect-hidden <hidden network name>
                iwctl station wlan0 connect-hidden " R
                iwctl station wlan0 connect-hidden $R
                break ;;
            4) iwctl station wlan0 get-networks > iwctl.txt
                echo "Use 'q' button to Quit." >> iwctl.txt
                echo "[$P@$Q $U]# press 'y' to read iwctl.txt"
                less iwctl.txt -F
                rm -rf iwctl.txt
                break ;;
            5) read -r -p "iwctl " R
                iwctl $R
                continue ;;
            "") continue ;;
            fF) break ;;
        esac
            echo "[$P@$Q $U]# Trying to ping ping.archlinux.org"
            ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "[$P@$Q $U]# ping ping.archlinux.org succesfull, continuing."
            break
        else
        echo "[$P@$Q $U]# ping ping.archlinux.org failed, check wifi connection / local area internet status before re-trying."
        continue
        fi ;;
esac
done


while true; do # timezone setting stage
read -r -p "[$P@$Q $U]# '1' to list timezones, and type the timezones to set the timezone (Area/Location (e.g. Asia/Jakarta)): " T
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
echo "[$P@$Q $U]# Current date & time:"
timedatectl
done


while true; do # partition creation stage
read -r -p "[$P@$Q $U]# fdisk:
    - '1' see all options,
    - '2' list partitions and disks in a .txt file,
    - '2b' use 'blkid' to list partitions and disks into a .txt file,
    - '2l' use 'lsblk' to list partitions and disks into a .txt file,
    - '3' create Empty Partition,
    - '4' create ESP (GPT, part. no. 1),
    - '5' create Boot Partition (MBR, part. no. 1),
    - '6' create Root Partition (GPT/MBR, part. no. 2),
    - '7' create empty partition (DIY) (input nothing to return here) (WIP),
    - '8' finish (use after finished creating partitions).
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
    3) read -r -p "[$P@$Q $U]# Which device would you like to choose to create the partition on?
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
            continue ;;
        *) continue ;;
        esac
        read -r -p "[$P@$Q $U]# In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $O in
        1) P="${S}M"
            B="MiB"
            U="M";;
        2) P="${S}G"
            B="GiB"
            U="G";;
        3) P="${S}T"
            B="TiB"
            U="T";;
        esac
        read -r -p "GPT (1) or MBR (2)" R
        case $R in
        1) T="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
            L="gpt" ;;
        2) T="83"
            L="dos";;
        esac
        read -r -p "How much (in $B) would you like to allocate to your new partition?" S
        read -r -p "What partition number would you give to your new partition?" N
        sudo sfdisk $D --wipe-table --force --quiet <<EOF
        label: $L
        unit: $U
        $N : size=$S, type=$T, name="DIR"
EOF
        DD="${D}$N"
        read -r -p "[$P@$Q $U]# Choose the format for your new partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - '5' for fat12.
        - '6' for fat16.
        - '7' for fat32
        - answer: " R
        case $R in
        1) FM="mkfs.f2fs" ;;
        2) FM="mkfs.btrfs" ;;
        3) FM="mkfs.xfs" ;;
        4) FM="mkfs.ext4" ;;
        5) FM="mkfs.fat -F 12" ;;
        6) FM="mkfs.fat -F 16" ;;
        7) FM="mkfs.fat -F 32" ;;
        *) continue
        *) continue ;;
        esac
        $FM $DD ;;
    4) read -r -p "[$P@$Q $U]# Which device would you like to choose to create the partition on?
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
            continue ;;
        *) continue ;;
        esac
        read -r -p "[$P@$Q $U]# In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $R in
        1) P="${S}M"
            B="MiB"
            U="M";;
        2) P="${S}G"
            B="GiB"
            U="G";;
        3) P="${S}T"
            B="TiB"
            U="T";;
        esac
        read -r -p "[$P@$Q $U]# How much (in $B) would you like to allocate to your new partition?" S
        sudo sfdisk $D --wipe-table --force --quiet <<EOF
        label: gpt
        unit: $U
        1 : size=$P, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="ESPDIR"
EOF
        ESPDIR="${D}1"
        echo "[$P@$Q $U]# Choose the fat size for ESP (12, 16, and 32 (32 is Recomended)) and choose the partition"
        read -r -p "[$P@$Q $U]# Which fat format would you like to use?
        - '1' for fat12.
        - '2' for fat16.
        - '3' for fat32
        - answer: " R
        case $R in
        1) FM= mkfs.fat -F 12 ;;
        2) FM= mkfs.fat -F 16 ;;
        3) FM= mkfs.fat -F 32 ;;
        *) continue
        esac
        echo "[$P@$Q $U]# creating ESP: $ESPDIR"
        $FM $ESPDIR
        ;;
    5) read -r -p "[$P@$Q $U]# Which device would you like to choose to create the partition on?
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
            continue ;;
        *) continue ;;
        esac
        read -r -p "[$P@$Q $U]# In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $R in
        1) P="${S}M"
            B="MiB"
            U="M";;
        2) P="${S}G"
            B="GiB"
            U="G";;
        3) P="${S}T"
            B="TiB"
            U="T";;
        esac
        read -r -p "[$P@$Q $U]# How much (in $B) would you like to allocate to your new partition?" S
        sudo sfdisk $D --wipe-table --force --quiet <<EOF
        label: dos
        unit: $U
        1 : size=$P, type=83, name="BOOTDIR"
EOF
        ESPDIR="${D}2"
        read -r -p "[$P@$Q $U]# Choose the format for Boot Partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - answer: " R
        case $R in
        1) FM="mkfs.f2fs" ;;
        2) FM="mkfs.btrfs" ;;
        3) FM="mkfs.xfs" ;;
        4) FM="mkfs.ext4" ;;
        *) continue ;;
        esac
        $FM $ESPDIR ;;
    6) read -r -p "[$P@$Q $U]# Which device would you like to choose to create the partition on?
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
            continue ;;
        *) continue ;;
        esac
        read -r -p "[$P@$Q $U]# In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " R
        case $R in
        1) P="${S}M"
            B="MiB"
            U="M";;
        2) P="${S}G"
            B="GiB"
            U="G";;
        3) P="${S}T"
            B="TiB"
            U="T";;
        esac
        read -r -p "[$P@$Q $U]# GPT (1) or MBR (2)" R
        case $R in
        1) T="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
            L="gpt" ;;
        2) T="83"
            L="dos";;
        esac
        read -r -p "[$P@$Q $U]# How much (in $B) would you like to allocate to your new partition?" S
        sudo sfdisk $DD --wipe-table --force --quiet <<EOF
        label: $L
        unit: $U
        2 : size=$P, type=$T, name="ROOTDIR"
EOF
        ROOTDIR="${D}2"
        read -r -p "[$P@$Q $U]# Choose the format for Root Partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - answer: " R
        case $R in
        1) FM="mkfs.f2fs" ;;
        2) FM="mkfs.btrfs" ;;
        3) FM="mkfs.xfs" ;;
        4) FM="mkfs.ext4" ;;
        *) continue ;;
        esac
        $FM $ROOTDIR ;;
    7) read -r -p " usage: fdisk <device>
            fdisk " R
            case $R in
            "") continue ;;
            *) fdisk $R
                continue ;;
            esac ;;
    8) if [ -z "$ROOTDIR" ]; then
            read -r -p "[$P@$Q $U]# Enter the full path for the ROOT partition (e.g., /dev/sda2): " ROOTDIR
        fi
        if [ -z "$ESPDIR" ]; then
            read -r -p "[$P@$Q $U]# Enter the full path for the ESP/BOOT partition (e.g., /dev/sda1): " ESPDIR
        fi
        read -r -p "[$P@$Q $U]# Are these paths correct? (y/n): " R
            case $R in
            [yY]*) break ;;
            *) continue ;; # Re-enter partition stage
            esac ;;
    esac
done


while true; do
    # alot of install stuffs
    read -r -p "[$P@$Q $U]# What username would you like to have? : " NEWUSER
    read -r -p "[$P@$Q $U]# What hostname would you like to have? : " HOSTNAME
    X="pacman -S --no-confirm kate gparted xarchiver xfce4-screenshooter xfce4-mount-plugin xfce4-mpc-plugin xfce4-clipman-plugin lutris steam mangohud xfce4-whiskermenu-plugin firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab cdrtools xorriso"
    Q="sudo -u "$NEWUSER" flatpak --noninteractive --user -y install sober zoom zapzap telegram"
    read -r -p "[$P@$Q $U]# Would you like to install extra packages (you can go to https://github.com/xv7ranker/minimalistui to see every packages (including extras))?
    - '1' install all extra packages,
    - '2' install extra pacman packages,
    - '3' install extra flatpak packages,
    - '0' do not install extra packages.
    - answer: " R
    case $R in
    1) ;;
    2) Q="echo "skipping installing extra flatpak packages."" ;;
    3) X="echo "skipping installing extra pacman packages."" ;;
    0) X="echo "skipping installing extra pacman packages.""
        Q="echo "skipping installing extra flatpak packages."" ;;
    "") continue ;;
    esac
    VENDORID=$(grep 'vendor_id' /proc/cpuinfo | head -n 1 | awk '{print $NF}')
    if [[ "$VENDORID" == "GenuineIntel" ]]; then
        C="intel-ucode"
        echo "[$P@$Q $U]# CPU is Intel, installing $C"
    elif [[ "$VENDORID" == "AuthenticAMD" ]]; then
        C="amd-ucode"
        echo "[$P@$Q $U]# CPU is AMD, installing $C"
    fi
    read -r -p "[$P@$Q $U]# Which GPU driver would you like to install?
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
            echo "[$P@$Q $U]# ERROR: Could not find UUID for Root Directory ($ROOTDIR). Check disk path."
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
    4) G="nvidia-dkms nvidia-settings nvidia-utils" ;;
    5) G="xf86-video-nouveau" ;;
    6) G="xf86-video-vesa" ;;
    7) G="xf86-video-vesa xf86-video-nouveau nvidia-dkms nvidia-settings nvidia-utils xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver xf86-video-ati xf86-video-amdgpu vulkan-radeon"
        C="intel-ucode amd-ucode" ;;
    esac
    mkdir /mnt
    mkdir /mnt/boot
    mount $ROOTDIR /mnt
    mount $ESPDIR /mnt/boot
    read -r -p "[$P@$Q $U]# What language would you like to set? ('1' to see all options) : " R
    case $R in
    1) less /mnt/etc/locale.gen
        echo "delete '#' and add . between locale and charset" >> /mnt/etc/locale.gen
        continue ;;
    "") continue ;;
    esac
    pacstrap -K /mnt base base-devel linux-zen linux-firmware efibootmgr networkmanager dhcpcd iwd xorg-server xorg-xinit polkit-gnome fontconfig mesa libva mesa-vdpau libva-mesa-driver f2fs-tools lvm2 mdadm xfsprogs e2fsprogs fzf bat zoxide lf thefuck ntfs-3g unzip p7zip unrar gufw ufw  neovim squashfs-tools $G $C
    genfstab -U /mnt >> /mnt/etc/fstab
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap defaults 0 0" >> /etc/fstab
    mv /minui /mnt/minui
    cp -r /var/lib/iwd/ /mnt/var/lib/iwd/
    cp -r /etc/NetworkManager/system-connections/ /mnt/etc/NetworkManager/system-connections/
    cp -r /etc/vconsole.conf /mnt/etc/vconsole.conf
    arch-chroot /mnt <<EOF
    T=$(pwd)
    P=$(whoami)
    U=$(basename "$T")
    Q=$(cat /etc/hostname)
    ln -sf /usr/share/zoneinfo/$T /etc/localtime
    hwclock --systohc
    locale-gen $R
    echo "LANG=$R
    LC_ADDRESS=$R
    LC_IDENTIFICATION=$R
    LC_MEASUREMENT=$R
    LC_MONETARY=$R
    LC_NAME=$R
    LC_NUMERIC=$R
    LC_PAPER=$R
    LC_TELEPHONE=$R
    LC_TIME=$R" > /etc/locale.conf
    echo "# modify the language to your option" >> /etc/locale.conf
    echo "# use ctrl+s to save and ctrl+x to exit after finishing modifying file" >> /etc/locale.conf
    nano /etc/locale.conf
    echo "KEYMAP=$K" >> /etc/vconsole.conf
    echo "$HOSTNAME" >> /etc/hostname
    echo "[$P@$Q $U]# Creating account"
    useradd -m -G wheel,audio,video,storage,power -s /bin/bash "$NEWUSER"
    echo "[$P@$Q $U]# You can modify root account password using command "passwd" while being root user or "sudo passwd" if you are using user account and you didnt know what your root account password is"
    echo "[$P@$Q $U]# Set your new user password"
    passwd "$NEWUSER"
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/99_wheel_config
    echo '#!/bin/bash' > /home/"$NEWUSER"/.xinitrc
    echo 'exec startxfce4' >> /home/"$NEWUSER"/.xinitrc
    echo '#!/bin/bash' > /home/"$NEWUSER"/.bash_profile
    echo '# Auto-start XFCE on TTY1 if no X session is running' >> /home/"$NEWUSER"/.bash_profile
    echo 'if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then' >> /home/"$NEWUSER"/.bash_profile
    echo '    exec startx' >> /home/"$NEWUSER"/.bash_profile
    echo 'fi' >> /home/"$NEWUSER"/.bash_profile
    echo 'fastfetch' >> /home/"$NEWUSER"/.bashrc
    echo 'cpufetch' >> /home/"$NEWUSER"/.bashrc
    mkdir /home/"$NEWUSER"/media
    ln -sf /run/"$NEWUSER" /home/"$NEWUSER"/media
    chown -R "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"
    chmod +x /home/"$NEWUSER"/.xinitrc
    chmod +x /home/"$NEWUSER"/.bash_profile
    bootctl install
    echo "[$P@$Q $U]# Installing DE Packages & Some Extras."
    pacman -S --noconfirm xfce4 volctl pasystray thunar flatpak kvantum mpv tint2 papirus-icon-theme xfce4-battery-plugin xfce4-notifyd xfce4-pulseaudio-plugin fastfetch cpufetch htop pipewire-alsa pipewire-pulse pipewire-jack pipewire bash-completion mpd kitty ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji materia-gtk-theme firefox udisks2 gvfs network-manager-applet pavucontrol firefox-i18n-en-us git thunar-archive-plugin thunar-media-tags-plugin thunar-vcs-plugin thunar-volman
    $X
    $Q
    git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git)
    cd yay
    makepkg -si
    cd /minui
    chmod +x /minui/execute.sh
    sh execute.sh
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
    read -r -p "[$P@$Q $U]# MinimalistUI finished installing, enter '1' to exit (make sure to unplug the installation media too after this)" R
    if [[ "$R" =~ ^[1]$ ]]; then
    umount -R /mnt
    exit
    break
    else
    continue
    fi
    done
    reboot
