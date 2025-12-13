#!/bin/bash

while true; do
if [[ $EUID -ne 0 ]]; then # 1st stage, sudo
    echo "ERROR: Must run with sudo."
    read -r -p "Rerun with sudo? (y/n): " SUDO
    case $SUDO in
    yY) exec sudo "$0" "$@" ;;
    "") continue ;;
    *) echo "Exiting."
       exit 1 ;;
    esac
fi
done

read -r -p "Do you want to change console keyboard layout and font? (y/n): " CHANGEFONT

while true; do # console font & keyboard layout setting stage
case $CHANGEFONT in
yY) read -r -p "Change your keyboard layout to:
- '1' to see all options,
- 'us' to set keyboard layout to US (Default),
- 'de-latin1' to set keyboard layout to German.
-  answer: " KEYBOARD
    case $KEYBOARD in
    1) localectl list-keymaps > keymaps.txt
        echo "Use 'q' button to Quit." >> keymaps.txt
        less keymaps.txt
        continue ;;
    "") continue ;;
    *) if localectl list-keymaps | grep -q "^$KEYBOARD$"; then
        loadkeys $KEYBOARD
        rm -rf keymaps.txt
        break
        else
        echo "Keyboard layout "$KEYBOARD" not found, try again."
        continue ;;
    esac
    read -r -p "Change your console font to:
    - '1' see all options,
    - 'ter-132b' for HiDPI screens (arch installation guide recomendation).
    -  answer: " CONSOLEFONT
        case $CONSOLEFONT in
        1) ls /usr/share/kbd/consolefonts > fonts.txt
            echo "When changing font, add the format of the font you want to change to, like if you want to change to
            iso01.08, you should write iso01.08.gz." >> fonts.txt
            echo "Ignore files starting with 'README.'."
            echo "Use 'q' button to Quit." >> fonts.txt
            less fonts.txt
            continue ;;
        *) FONT_BASE_PATH="/usr/share/kbd/consolefonts/$RESPONSE"
            if [ -f "$FONT_BASE_PATH" ] || [ -f "$FONT_BASE_PATH.psf.gz" ] || [ -f "$FONT_BASE_PATH.psf" ]; then
                setfont $RESPONSE
                rm -rf fonts.txt
                break
            else
                echo "ERROR: Console font '$CONSOLEFONT' not found, try again."
                continue
            fi ;;
        "") continue ;;
        esac ;;
nN) echo "Not Changing Keyboard Layout (Default: US) and Console Font."
    break ;;
"") continue ;;
esac
done


while true; do # networking setting stage
    read -r -p "Networking:
    - '1' use ethernet,
    - '2' use wifi (complicated setup tbh),
    - '3' use wwan (WIP(???)).
    -  answer: " NETWORKING
case $NETWORKING in
    "") continue ;;
    dD) echo "Skipping connection."
        echo "Debugging Purpose Only."
        break ;;
    1) echo "Trying to ping ping.archlinux.org"
        ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "ping ping.archlinux.org succesfull, continuing."
            break
        else
            echo "ping ping.archlinux.org failed, check ethernet cable / internet status before re-trying."
            continue
        fi ;;
    3) echo "Trying to ping ping.archlinux.org"
        ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "ping ping.archlinux.org succesfull, continuing."
            break
        else
            echo "ping ping.archlinux.org failed, check cellular data amount left / local area internet status before re-trying."
            continue
        fi ;;
    2) read -r -p "iwctl:
        - '1' see all options,
        - '2' connect to network / wifis (wlan0),
        - '3' connect to hidden network / wifis (wlan0),
        - '4' see all connectable connections / wifis (wlan0),
        - '5' enter your own command (input nothing to return here),
        - 'f' finish (skip, can be used after using option 5).
        -  answer: " WIFI
        case $WIFI in
            1) iwctl help > iwctl.txt
                echo "Use 'q' button to Quit." >> fonts.txt
                echo "press 'y' to read iwctl.txt"
                less iwctl.txt -F
                rm -rf iwctl.txt
                continue ;;
            2) read -r -p "usage: iwctl station wlan0 connect <network name> <security protocol>
                iwctl station wlan0 connect " RESPONSE
                iwctl station wlan0 connect $RESPONSE
                break ;;
            3) read -r -p "usage: iwctl station wlan0 connect-hidden <hidden network name>
                iwctl station wlan0 connect-hidden " RESPONSE
                iwctl station wlan0 connect-hidden $RESPONSE
                break ;;
            4) iwctl station wlan0 get-networks
                break ;;
            5) read -r -p "iwctl " RESPONSE
                iwctl $RESPONSE
                continue ;;
            "") continue ;;
            fF) break ;;
        esac
            echo "Trying to ping ping.archlinux.org"
            ping -c 1 -w 5 ping.archlinux.org > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "ping ping.archlinux.org succesfull, continuing."
            break
        else
        echo "ping ping.archlinux.org failed, check wifi connection / local area internet status before re-trying."
        continue
        fi ;;
esac
done

while true; do # timezone setting stage
read -r -p "'1' to list timezones, and type the timezones to set the timezone (Area/Location (e.g. Asia/Jakarta)): " TIMEZONE
    case $TIMEZONE in
    1) timedatectl list-timezones > timezones.txt
        echo "Use 'q' button to Quit." >> timezones.txt
        less timezones.txt
        rm -rf timezones.txt
        continue ;;
    *) timedatectl set-timezones $TIMEZONE
        break ;;
    "") continue ;;
    esac
echo "Current date & time:"
timedatectl
done

while true; do # partition creation stage
read -r -p "fdisk:
    - '1' see all options,
    - '2' list partitions and disks in a .txt file,
    - '2b' use 'blkid' to list partitions and disks into a .txt file,
    - '2l' use 'lsblk' to list partitions and disks into a .txt file,
    - '3' create Empty Partition,
    - '4' create ESP (GPT, part. no. 1),
    - '5' create Boot Partition (MBR, part. no. 1),
    - '6' create Root Partition (GPT/MBR, part. no. 2),
    - '7' create empty partition (DIY) (input nothing to return here),
    - '8' finish (use after finished creating partitions).
    -  answer: " FDISK
    case $FDISK in
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
    3) read -r -p "Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmex' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " DD
        case $DD in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue ;;
        *) continue ;;
        esac
        read -r -p "In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " $DPS
        case $DPS in
        1) DDF="${DDSS}M"
            DDS="MiB"
            DDSU="M";;
        2) DDF="${DDSS}G"
            DDS="GiB"
            DDSU="G";;
        3) DDF="${DDSS}T"
            DDS="TiB"
            DDSU="T";;
        esac
        read -r -p "GPT (1) or MBR (2)" GPTMBR
        case $GPTMBR in
        1) TYPE="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
            LABEL="gpt" ;;
        2) TYPE="83"
            LABEL="dos";;
        esac
        read -r -p "How much (in $DDS) would you like to allocate to your new partition?" $DDSS
        read -r -p "What partition number would you give to your new partition?" PN
        sudo sfdisk $DD --wipe-table --force --quiet <<EOF
        label: $LABEL
        unit: $DDSU
        $PN : size=$DDF, type=$TYPE, name="DIR"
EOF
        DIR="${DD}$PN"
        read -r -p "Choose the format for your new partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - '5' for fat12.
        - '6' for fat16.
        - '7' for fat32
        - answer: " FS
        case $FS in
        1) FORMAT="mkfs.f2fs" ;;
        2) FORMAT="mkfs.btrfs" ;;
        3) FORMAT="mkfs.xfs" ;;
        4) FORMAT="mkfs.ext4" ;;
        5) FORMAT="mkfs.fat -F 12" ;;
        6) FORMAT="mkfs.fat -F 16" ;;
        7) FORMAT="mkfs.fat -F 32" ;;
        *) continue
        *) continue ;;
        esac
        $FORMAT $DIR ;;
    4) read -r -p "Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmex' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " DD
        case $DD in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue ;;
        *) continue ;;
        esac
        read -r -p "In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " $DPS
        case $DPS in
        1) DDF="${DDSS}M"
            DDS="MiB"
            DDSU="M";;
        2) DDF="${DDSS}G"
            DDS="GiB"
            DDSU="G";;
        3) DDF="${DDSS}T"
            DDS="TiB"
            DDSU="T";;
        esac
        read -r -p "How much (in $DDS) would you like to allocate to your new partition?" $DDSS
        sudo sfdisk $DD --wipe-table --force --quiet <<EOF
        label: gpt
        unit: $DDSU
        1 : size=$DDF, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="ESPDIR"
EOF
        ESPDIR="${DD}1"
        echo "Choose the fat size for ESP (12, 16, and 32 (32 is Recomended)) and choose the partition"
        read -r -p "Which fat format would you like to use?
        - '1' for fat12.
        - '2' for fat16.
        - '3' for fat32
        - answer: " FAT
        case $FAT in
        1) FATFORMAT= mkfs.fat -F 12 ;;
        2) FATFORMAT= mkfs.fat -F 16 ;;
        3) FATFORMAT= mkfs.fat -F 32 ;;
        *) continue
        esac
        echo "creating ESP: $ESPDIR"
        $FATFORMAT $ESPDIR
        ;;
    5) read -r -p "Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmex' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " DD
        case $DD in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue ;;
        *) continue ;;
        esac
        read -r -p "In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " $DPS
        case $DPS in
        1) DDF="${DDSS}M"
            DDS="MiB"
            DDSU="M";;
        2) DDF="${DDSS}G"
            DDS="GiB"
            DDSU="G";;
        3) DDF="${DDSS}T"
            DDS="TiB"
            DDSU="T";;
        esac
        read -r -p "How much (in $DDS) would you like to allocate to your new partition?" $DDSS
        sudo sfdisk $DD --wipe-table --force --quiet <<EOF
        label: dos
        unit: $DDSU
        1 : size=$DDF, type=83, name="BOOTDIR"
EOF
        ESPDIR="${DD}2"
        read -r -p "Choose the format for Boot Partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - answer: " ROOT
        case $ROOT in
        1) ROOTFORMAT="mkfs.f2fs" ;;
        2) ROOTFORMAT="mkfs.btrfs" ;;
        3) ROOTFORMAT="mkfs.xfs" ;;
        4) ROOTFORMAT="mkfs.ext4" ;;
        *) continue ;;
        esac
        $ROOTFORMAT $ROOTDIR ;;
    6) read -r -p "Which device would you like to choose to create the partition on?
        - '1' see all options,
        - '/dev/sdx' normally for sata devices x (change x with the right letter),
        - '/dev/nvmex' normally for nvme devices no. x (change x with the right number),
        - '/dev/mmcblkx' normally for microsd cards no. x (change x with the right number).
        - answer: " DD
        case $DD in
        1) lsblk > lsblk.txt
            echo "Use 'q' button to Quit." >> lsblk.txt
            less lsblk.txt
            rm -rf lsblk.txt
            continue ;;
        *) continue ;;
        esac
        read -r -p "In what size format would you like your new partition be made?
        - '1' use MiB,
        - '2' use GiB,
        - '3' use TiB.
        - answer: " $DPS
        case $DPS in
        1) DDF="${DDSS}M"
            DDS="MiB"
            DDSU="M";;
        2) DDF="${DDSS}G"
            DDS="GiB"
            DDSU="G";;
        3) DDF="${DDSS}T"
            DDS="TiB"
            DDSU="T";;
        esac
        read -r -p "GPT (1) or MBR (2)" GPTMBR
        case $GPTMBR in
        1) TYPE="0FC63DAF-8483-4772-8E79-3D69D8477DE4"
            LABEL="gpt" ;;
        2) TYPE="83"
            LABEL="dos";;
        esac
        read -r -p "How much (in $DDS) would you like to allocate to your new partition?" $DDSS
        sudo sfdisk $DD --wipe-table --force --quiet <<EOF
        label: $LABEL
        unit: $DDSU
        2 : size=$DDF, type=$TYPE, name="ROOTDIR"
EOF
        ROOTDIR="${DD}2"
        read -r -p "Choose the format for Root Partition
        - '1' F2FS, recomended for ssds... supposedly,
        - '2' BTRFS, modern, feature-rich...,
        - '3' XFS, recomended for big files... supposedly,
        - '4' EXT4, classic...
        - answer: " ROOT
        case $ROOT in
        1) ROOTFORMAT="mkfs.f2fs" ;;
        2) ROOTFORMAT="mkfs.btrfs" ;;
        3) ROOTFORMAT="mkfs.xfs" ;;
        4) ROOTFORMAT="mkfs.ext4" ;;
        *) continue ;;
        esac
        $ROOTFORMAT $ROOTDIR ;;
    7) read -r -p " usage: fdisk <device>
            fdisk " DIYFDISK
            case $DIYFDISK in
            "") continue ;;
            *) fdisk $DIYFDISK
                continue ;;
            esac ;;
    8) break ;;
    esac
done

while true; do
    echo "message for dev: everything after line 320 should be tidied" # alot of install stuffs
    echo "for extra downloadables, remove the "#" on line 1095 & 1096"
    read -r -p "What username would you like to have? : " NEWUSER
    read -r -p "What hostname would you like to have? : " HOSTNAME
    read -r -p "Which GPU driver would you like to install?
    - '1' to install AMD GPU Driver (Modern (xf86-video-amdgpu)) + Vulkan (vulkan-radeon) + Mesa (Depend.)
    - '2' to install AMD GPU Driver (Old (xf86-video-ati)) + Mesa (Default)
    - '3' to install Intel GPU Driver (xf86-video-intel) + Vulkan (vulkan-intel) + Mesa (Depend.) + Media Driver (Extra)
          (Compatible w/ older non-vulkan igps)
    - '4' to install NVIDIA GPU Driver (Proprietary (nvidia-dkms + nvidia-settings)) + Vulkan (Incl.) Mesa (Default)
    - '5' to install NVIDIA GPU Driver (Open Source (xf86-video-nouveau)) + Mesa (Default) (No Vulkan (???))
    - '6' to install Generic Fallback Driver (NOT RECOMENDED FOR NEWER SYSTEMS, USE AS FALLBACK ONLY) (xf86-video-vesa) + Mesa (Default)
    - answer: " GPUI
    if [ -n "$ESPDIR" ] && [ -n "$ROOTDIR" ] && [ -n "$NEWUSER" ] && [ -n "$GPUI" ]; then
        ROOT_UUID=$(blkid -s UUID -o value "$ROOTDIR")
        if [ -z "$ROOT_UUID" ]; then
            echo "ERROR: Could not find UUID for Root Directory ($ROOTDIR). Check disk path."
            continue
        fi
        break
    else
        continue
    fi
    done
    case $GPUI in
    1) GPU="xf86-video-amdgpu vulkan-radeon" ;;
    2) GPU="xf86-video-ati" ;;
    3) GPU="xf86-video-intel vulkan-intel intel-media-driver libva-intel-driver" ;;
    4) GPU="nvidia-dkms nvidia-settings nvidia-utils" ;;
    5) GPU="xf86-video-nouveau" ;;
    6) GPU="xf86-video-vesa" ;;
    esac
    mkdir /mnt
    mkdir /mnt/boot
    mount $ROOTDIR /mnt
    mount $ESPDIR /mnt/boot
    read -r -p "What language would you like to set? ('1' to see all options) : " LOCALE
    case $LOCALE in
    1) less /etc/locale.gen
        echo "delete '#' and add . between locale and charset"
        continue ;;
    "") continue ;;
    esac
    VENDORID=$(grep 'vendor_id' /proc/cpuinfo | head -n 1 | awk '{print $NF}')
    if [[ "$VENDORID" == "GenuineIntel" ]]; then
        CPU="intel-ucode"
    elif [[ "$VENDORID" == "AuthenticAMD" ]]; then
        CPU="amd-ucode"
    fi
    pacstrap -K /mnt base linux-zen linux-firmware xorg-server xorg-xinit polkit-gnome fontconfig networkmanager dhcpcd mesa libva mesa-vdpau libva-mesa-driver f2fs-tools nano bash fzf bat zoxide lf thefuck systemd yay ntfs-3g unzip p7zip unrar gufw ufw $GPU $CPU
    genfstab -U /mnt >> /mnt/etc/fstab
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap defaults 0 0" >> /etc/fstab
    arch-chroot /mnt <<EOF
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    locale-gen $LOCALE
    echo "LANG=$LOCALE
    LC_ADDRESS=$LOCALE
    LC_IDENTIFICATION=$LOCALE
    LC_MEASUREMENT=$LOCALE
    LC_MONETARY=$LOCALE
    LC_NAME=$LOCALE
    LC_NUMERIC=$LOCALE
    LC_PAPER=$LOCALE
    LC_TELEPHONE=$LOCALE
    LC_TIME=$LOCALE" > /etc/locale.conf
    echo "# modify the language to your option" >> /etc/locale.conf
    echo "# use ctrl+s to save and ctrl+x to exit after finishing modifying file" >> /etc/locale.conf
    nano /etc/locale.conf
    echo "KEYMAP=$KEYBOARD" >> /etc/vconsole.conf
    echo "$HOSTNAME" >> /etc/hostname
    echo "Creating account"
    useradd -m -G wheel,audio,video,storage,power -s /bin/bash "$NEWUSER"
    echo "You can modify root account password using command "passwd" while being root user or "sudo passwd" if you are using user account and you didnt know what your root account password is"
    echo "Set your new user password"
    passwd "$NEWUSER"
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/99_wheel_config
    echo '#!/bin/bash' > /home/"$NEWUSER"/.xinitrc
    echo 'exec startxfce4' >> /home/"$NEWUSER"/.xinitrc
    echo '#!/bin/bash' > /home/"$NEWUSER"/.bash_profile
    echo '# Auto-start XFCE on TTY1 if no X session is running' >> /home/"$NEWUSER"/.bash_profile
    echo 'if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then' >> /home/"$NEWUSER"/.bash_profile
    echo '    exec startx' >> /home/"$NEWUSER"/.bash_profile
    echo 'fi' >> /home/"$NEWUSER"/.bash_profile
    echo 'fastfetch' > /home/"$NEWUSER"/.bashrc
    echo 'cpufetch' > /home/"$NEWUSER"/.bashrc
    mkdir /home/"$NEWUSER"/media
    ln -sf /run/"$NEWUSER" /home/"$NEWUSER"/media
    chown -R "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"
    chmod +x /home/"$NEWUSER"/.xinitrc
    chmod +x /home/"$NEWUSER"/.bash_profile
    bootctl install
    echo "title MinimalistUI
    linux /boot/vmlinuz-linux-zen
    initrd /boot/initramfs-linux-zen.img
    options nvme_load=YES nowatchdog root=UUID=$ROOT_UUID rw loglevel=3 swapfile=/swapfile" > /boot/loader/entries/minui.conf
    echo "title MinimalistUI (CLI)
    linux /boot/vmlinuz-linux-zen
    initrd /boot/initramfs-linux-zen.img
    options nvme_load=YES nowatchdog root=UUID=$ROOT_UUID rw loglevel=3 swapfile=/swapfile systemd.unit=multi-user.target" > /boot/loader/entries/minuicli.conf
    echo "Creating command to switch cpu governor to performance or powersave (use command cpu-performance or cpu-powersave)"
    sh -c 'cat << EOF > /usr/local/bin/cpu-maxperf
    #!/bin/bash
    if [[ $EUID -ne 0 ]]; then # 1st stage, sudo
        echo "ERROR: Must run with sudo."
        read -r -p "Rerun with sudo? (y/n): " RESPONSE
        if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
            exec sudo "$0" "$@"
        else
            echo "Exiting."
        exit 1
        fi
    fi
    for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > $CPU
    done
    echo "10" > /proc/sys/vm/swappiness > /dev/null 2>&1
    EOF'
    chmod +x /usr/local/bin/cpu-maxperf
    sudo sh -c 'cat << EOF > /usr/local/bin/cpu-powersave
    #!/bin/bash
    if [[ $EUID -ne 0 ]]; then # 1st stage, sudo
        echo "ERROR: Must run with sudo."
        read -r -p "Rerun with sudo? (y/n): " RESPONSE
        if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
            exec sudo "$0" "$@"
        else
            echo "Exiting."
        exit 1
        fi
    fi
    for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "powersave" > $CPU
    done
    echo "10" > /proc/sys/vm/swappiness > /dev/null 2>&1
    EOF'
    chmod +x /usr/local/bin/cpu-powersave
    echo "Creating command to increase or decrease brightness (use command brightness)"
    sh -c 'cat << EOF > /usr/local/bin/brightness
    #!/bin/bash
    # Usage: brightness [1-100]

    MIN_BRIGHTNESS_LIMIT=1
    MAX_BRIGHTNESS_LIMIT=100
    PERCENTAGE=$1

    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: Must run with sudo."
        read -r -p "Rerun with sudo? (y/n): " RESPONSE

        if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
            exec sudo "$0" "$@"
        else
            echo "Exiting."
            exit 1
        fi
    fi

    if [ -z "$PERCENTAGE" ]; then
        echo "Usage: sudo brightness [1-$MAX_BRIGHTNESS_LIMIT]"
        exit 1
    fi

    # Input validation
    if ! [[ $PERCENTAGE =~ ^[0-9]+$ ]] || [ "$PERCENTAGE" -lt "$MIN_BRIGHTNESS_LIMIT" ] || [ "$PERCENTAGE" -gt "$MAX_BRIGHTNESS_LIMIT" ]; then
        echo "Error: Brightness must be between $MIN_BRIGHTNESS_LIMIT and $MAX_VOLUME_LIMIT."
        exit 1
    fi

    # --- FUNCTION: KERNEL (SYSFS) BRIGHTNESS CALCULATION ---
    set_sysfs_brightness() {
        local DIR="$1"

        if [ ! -d "$DIR" ] || [ ! -f "$DIR/max_brightness" ] || [ ! -f "$DIR/brightness" ]; then
            return 1
        fi

        MAX_BRIGHTNESS=$(cat "$DIR/max_brightness")

        NEW_VALUE=$((PERCENTAGE * MAX_BRIGHTNESS / 100))

        if [ "$NEW_VALUE" -lt 1 ]; then
            NEW_VALUE=1
        fi

        echo "$NEW_VALUE" | tee "$DIR/brightness" > /dev/null

        # REPORTING TIER 1
        echo "Brightness set to $PERCENTAGE% (Method: /sys/class/backlight/)."
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
        sudo -u $SUDO_USER     DISPLAY=$DISPLAY     XAUTHORITY=$XAUTHORITY     light -S "$PERCENTAGE" 2>/dev/null

        if [ $? -eq 0 ]; then
            # REPORTING TIER 2
            echo "Brightness set to $PERCENTAGE% (Method: light)."
            exit 0
        fi
    fi


    # FINAL ERROR MESSAGE
    echo "Error: Failed to set brightness."
    echo "Install light or check path."
    exit 1
    EOF'
    chmod +x /usr/local/bin/brightness
    echo "Creating command to increase / decrease / mute volume (intended for cli environtment) (use command volume)"
    sh -c 'cat << EOF > /usr/local/bin/volume
    #!/bin/bash
    # Usage: volume [0-150] | volume mute

    COMMAND=$1
    MAX_VOLUME_LIMIT=150

    if [ -z "$COMMAND" ]; then
        echo "Usage: volume [0-$MAX_VOLUME_LIMIT] or volume mute"
        exit 1
    fi

    if command -v pactl &> /dev/null; then

        # --- MUTE OPTION ---
        if [ "$COMMAND" == "mute" ]; then
            pactl set-sink-mute @DEFAULT_SINK@ toggle

            if [ $? -eq 0 ]; then
                # Check the NEW mute status after toggle and CLEAN THE OUTPUT
                # tr -d "\r\n" ensures MUTE_STATUS is exactly "yes" or "no"
                MUTE_STATUS=$(pactl get-sink-mute @DEFAULT_SINK@ | awk "{print $2}" | tr -d "\r\n")

                if [ "$MUTE_STATUS" == "yes" ]; then
                    echo "Volume set to muted."
                else
                    echo "Volume set to unmuted."
                fi
                exit 0
            fi
        fi

        # --- PERCENTAGE OPTION ---
        PERCENTAGE=$COMMAND

        if ! [[ $PERCENTAGE =~ ^[0-9]+$ ]] || [ "$PERCENTAGE" -lt 0 ] || [ "$PERCENTAGE" -gt "$MAX_VOLUME_LIMIT" ]; then
            echo "Error: Volume percentage must be between 0 and $MAX_VOLUME_LIMIT."
            exit 1
        fi

        # Set volume
        pactl set-sink-volume @DEFAULT_SINK@ "$PERCENTAGE%"

        if [ $? -eq 0 ]; then
            echo "Volume set to $PERCENTAGE%."
            exit 0
        else
            echo "Error: Failed to adjust volume."
            exit 1
        fi
    else
        echo "Error: pactl not found."
        exit 1
    fi
    EOF'
    chmod +x /usr/local/bin/volume
    echo "Creating command to use mpv in CLI-only environtment (use command vlcwatch)"
    sh -c 'cat << EOF > /usr/local/bin/vlcwatch
    #!/bin/bash
    USER="find /home -maxdepth 1 -mindepth 1 -type d -not -name 'lost+found' -printf '%f\n' | shuf -n 1"
    if [ -z "$1" ]; then
        echo "Usage: mpvwatch <video_file> [vlc_options]"
        echo "This Command Is Only Available In CLI Environment."
        echo "Run "mpv --help" for available options."
        exit 1
    fi
    if [[ $EUID -eq 0 ]]; then
        sudo -u $USER mpv --vo=drm "$@"
        exit 1
    fi
    mpv --vo=drm "$@"
    exit 1
    EOF'
    chmod +x /usr/local/bin/vlcwatch
    echo "For commands that are focused on CLI-Only environtment, use command "ls /usr/local/bin" to see the commands."
    echo "<?xml version="1.1" encoding="UTF-8"?>

<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=683;y=754"/>
      <property name="length" type="double" value="1"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="20"/>
      <property name="size" type="uint" value="32"/>
      <property name="enable-struts" type="bool" value="true"/>
      <property name="mode" type="uint" value="0"/>
      <property name="autohide-behavior" type="uint" value="2"/>
      <property name="enter-opacity" type="uint" value="0"/>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0"/>
        <value type="double" value="0"/>
        <value type="double" value="0"/>
        <value type="double" value="1"/>
      </property>
      <property name="length-adjust" type="bool" value="false"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
      </property>
      <property name="leave-opacity" type="uint" value="0"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="clipman" type="empty">
      <property name="settings" type="empty">
        <property name="show-qr-code" type="bool" value="true"/>
        <property name="add-primary-clipboard" type="bool" value="true"/>
      </property>
      <property name="tweaks" type="empty">
        <property name="popup-at-pointer" type="bool" value="false"/>
        <property name="max-menu-items" type="uint" value="25"/>
      </property>
    </property>
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="favorites" type="array">
        <value type="string" value="xfce4-file-manager.desktop"/>
        <value type="string" value="xfce4-terminal-emulator.desktop"/>
      </property>
      <property name="category-icon-size" type="int" value="2"/>
      <property name="position-categories-horizontal" type="bool" value="false"/>
      <property name="position-categories-alternate" type="bool" value="true"/>
      <property name="position-profile-alternate" type="bool" value="false"/>
      <property name="position-search-alternate" type="bool" value="true"/>
      <property name="default-category" type="int" value="2"/>
      <property name="show-button-icon" type="bool" value="true"/>
      <property name="show-button-title" type="bool" value="false"/>
      <property name="button-title" type="string" value="Applications"/>
      <property name="button-icon" type="string" value="false"/>
    </property>
  </property>
</channel>
" > /home/"$NEWUSER"/,config/xfce4/xfconf/xfce4-perchannel-xml/xfce4-panel.xml
    echo "<?xml version="1.1" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="activate_action" type="string" value="bring"/>
    <property name="borderless_maximize" type="bool" value="true"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
    <property name="button_layout" type="string" value="O|SHMC"/>
    <property name="button_offset" type="int" value="0"/>
    <property name="button_spacing" type="int" value="0"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="cycle_apps_only" type="bool" value="false"/>
    <property name="cycle_draw_frame" type="bool" value="true"/>
    <property name="cycle_raise" type="bool" value="false"/>
    <property name="cycle_hidden" type="bool" value="true"/>
    <property name="cycle_minimum" type="bool" value="true"/>
    <property name="cycle_minimized" type="bool" value="false"/>
    <property name="cycle_preview" type="bool" value="false"/>
    <property name="cycle_tabwin_mode" type="int" value="0"/>
    <property name="cycle_workspaces" type="bool" value="false"/>
    <property name="double_click_action" type="string" value="maximize"/>
    <property name="double_click_distance" type="int" value="5"/>
    <property name="double_click_time" type="int" value="250"/>
    <property name="easy_click" type="string" value="Alt"/>
    <property name="focus_delay" type="int" value="250"/>
    <property name="focus_hint" type="bool" value="true"/>
    <property name="focus_new" type="bool" value="true"/>
    <property name="frame_opacity" type="int" value="100"/>
    <property name="frame_border_top" type="int" value="0"/>
    <property name="full_width_title" type="bool" value="true"/>
    <property name="horiz_scroll_opacity" type="bool" value="false"/>
    <property name="inactive_opacity" type="int" value="100"/>
    <property name="maximized_offset" type="int" value="0"/>
    <property name="mousewheel_rollup" type="bool" value="true"/>
    <property name="move_opacity" type="int" value="100"/>
    <property name="placement_mode" type="string" value="center"/>
    <property name="placement_ratio" type="int" value="20"/>
    <property name="popup_opacity" type="int" value="100"/>
    <property name="prevent_focus_stealing" type="bool" value="false"/>
    <property name="raise_delay" type="int" value="250"/>
    <property name="raise_on_click" type="bool" value="true"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_with_any_button" type="bool" value="true"/>
    <property name="repeat_urgent_blink" type="bool" value="false"/>
    <property name="resize_opacity" type="int" value="100"/>
    <property name="scroll_workspaces" type="bool" value="true"/>
    <property name="shadow_delta_height" type="int" value="0"/>
    <property name="shadow_delta_width" type="int" value="0"/>
    <property name="shadow_delta_x" type="int" value="0"/>
    <property name="shadow_delta_y" type="int" value="-3"/>
    <property name="shadow_opacity" type="int" value="50"/>
    <property name="show_app_icon" type="bool" value="false"/>
    <property name="show_dock_shadow" type="bool" value="false"/>
    <property name="show_frame_shadow" type="bool" value="false"/>
    <property name="show_popup_shadow" type="bool" value="false"/>
    <property name="snap_resist" type="bool" value="false"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="false"/>
    <property name="snap_width" type="int" value="10"/>
    <property name="vblank_mode" type="string" value="auto"/>
    <property name="theme" type="string" value="Default"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Sans Bold 9"/>
    <property name="title_horizontal_offset" type="int" value="0"/>
    <property name="titleless_maximize" type="bool" value="false"/>
    <property name="title_shadow_active" type="string" value="false"/>
    <property name="title_shadow_inactive" type="string" value="false"/>
    <property name="title_vertical_offset_active" type="int" value="0"/>
    <property name="title_vertical_offset_inactive" type="int" value="0"/>
    <property name="toggle_workspaces" type="bool" value="false"/>
    <property name="unredirect_overlays" type="bool" value="false"/>
    <property name="urgent_blink" type="bool" value="false"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="workspace_count" type="int" value="1"/>
    <property name="wrap_cycle" type="bool" value="true"/>
    <property name="wrap_layout" type="bool" value="true"/>
    <property name="wrap_resistance" type="int" value="10"/>
    <property name="wrap_windows" type="bool" value="false"/>
    <property name="wrap_workspaces" type="bool" value="false"/>
    <property name="zoom_desktop" type="bool" value="false"/>
    <property name="zoom_pointer" type="bool" value="false"/>
    <property name="workspace_names" type="array">
      <value type="string" value="Ruang kerja 1"/>
      <value type="string" value="Ruang kerja 2"/>
      <value type="string" value="Ruang kerja 3"/>
      <value type="string" value="Ruang kerja 4"/>
    </property>
  </property>
</channel>
" > /home/"$NEWUSER"/,config/xfce4/xfconf/xfce4-perchannel-xml/xfwm4.xml
    echo "<?xml version="1.1" encoding="UTF-8"?>

<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Alt&gt;F1" type="empty"/>
      <property name="&lt;Alt&gt;F2" type="empty">
        <property name="startup-notify" type="empty"/>
      </property>
      <property name="&lt;Alt&gt;F3" type="empty">
        <property name="startup-notify" type="empty"/>
      </property>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;l" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="empty"/>
      <property name="XF86Display" type="empty"/>
      <property name="&lt;Super&gt;p" type="empty"/>
      <property name="&lt;Primary&gt;Escape" type="empty"/>
      <property name="XF86WWW" type="empty"/>
      <property name="HomePage" type="empty"/>
      <property name="XF86Mail" type="empty"/>
      <property name="Print" type="empty"/>
      <property name="&lt;Alt&gt;Print" type="empty"/>
      <property name="&lt;Shift&gt;Print" type="empty"/>
      <property name="&lt;Super&gt;e" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;f" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Escape" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;Escape" type="empty"/>
      <property name="&lt;Super&gt;r" type="empty">
        <property name="startup-notify" type="empty"/>
      </property>
      <property name="&lt;Alt&gt;&lt;Super&gt;s" type="empty"/>
    </property>
    <property name="custom" type="empty">
      <property name="Print" type="string" value="xfce4-screenshooter"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="string" value="xfce4-session-logout"/>
      <property name="override" type="bool" value="true"/>
      <property name="Super_L" type="string" value="/usr/bin/xfce4-popup-whiskermenu"/>
      <property name="&lt;Super&gt;p" type="string" value="xfce4-display-settings --minimal"/>
      <property name="&lt;Super&gt;i" type="string" value="xfce4-settings-manager"/>
      <property name="&lt;Shift&gt;&lt;Super&gt;s" type="string" value="xfce4-screenshooter"/>
      <property name="&lt;Super&gt;r" type="string" value="rofi -show drun">
        <property name="startup-notify" type="bool" value="true"/>
      </property>
      <property name="&lt;Super&gt;d" type="string" value="kitty --start-as hidden xdotool key &quot;ctrl+alt+d&quot;"/>
      <property name="&lt;Super&gt;q" type="string" value="kitty --start-as maximized"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;Escape" type="string" value="kitty --start-as maximized htop"/>
      <property name="&lt;Shift&gt;&lt;Super&gt;e" type="string" value="pkexec pcmanfm /home/kata"/>
      <property name="&lt;Super&gt;e" type="string" value="pcmanfm"/>
    </property>
  </property>
  <property name="xfwm4" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Alt&gt;Insert" type="empty"/>
      <property name="Escape" type="empty"/>
      <property name="Left" type="empty"/>
      <property name="Right" type="empty"/>
      <property name="Up" type="empty"/>
      <property name="Down" type="empty"/>
      <property name="&lt;Alt&gt;Tab" type="empty"/>
      <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="empty"/>
      <property name="&lt;Alt&gt;Delete" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Down" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Left" type="empty"/>
      <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Down" type="empty"/>
      <property name="&lt;Alt&gt;F4" type="empty"/>
      <property name="&lt;Alt&gt;F6" type="empty"/>
      <property name="&lt;Alt&gt;F7" type="empty"/>
      <property name="&lt;Alt&gt;F8" type="empty"/>
      <property name="&lt;Alt&gt;F9" type="empty"/>
      <property name="&lt;Alt&gt;F10" type="empty"/>
      <property name="&lt;Alt&gt;F11" type="empty"/>
      <property name="&lt;Alt&gt;F12" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Left" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;End" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Home" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Right" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Up" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_1" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_2" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_3" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_4" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_5" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_6" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_7" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_8" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_9" type="empty"/>
      <property name="&lt;Alt&gt;space" type="empty"/>
      <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Up" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Right" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;d" type="empty"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Up" type="empty"/>
      <property name="&lt;Super&gt;Tab" type="empty"/>
      <property name="&lt;Primary&gt;F1" type="empty"/>
      <property name="&lt;Primary&gt;F2" type="empty"/>
      <property name="&lt;Primary&gt;F3" type="empty"/>
      <property name="&lt;Primary&gt;F4" type="empty"/>
      <property name="&lt;Primary&gt;F5" type="empty"/>
      <property name="&lt;Primary&gt;F6" type="empty"/>
      <property name="&lt;Primary&gt;F7" type="empty"/>
      <property name="&lt;Primary&gt;F8" type="empty"/>
      <property name="&lt;Primary&gt;F9" type="empty"/>
      <property name="&lt;Primary&gt;F10" type="empty"/>
      <property name="&lt;Primary&gt;F11" type="empty"/>
      <property name="&lt;Primary&gt;F12" type="empty"/>
      <property name="&lt;Super&gt;KP_Left" type="empty"/>
      <property name="&lt;Super&gt;KP_Right" type="empty"/>
      <property name="&lt;Super&gt;KP_Down" type="empty"/>
      <property name="&lt;Super&gt;KP_Up" type="empty"/>
      <property name="&lt;Super&gt;KP_Page_Up" type="empty"/>
      <property name="&lt;Super&gt;KP_Home" type="empty"/>
      <property name="&lt;Super&gt;KP_End" type="empty"/>
      <property name="&lt;Super&gt;KP_Next" type="empty"/>
    </property>
    <property name="custom" type="empty">
      <property name="&lt;Primary&gt;F12" type="string" value="workspace_12_key"/>
      <property name="&lt;Super&gt;KP_Down" type="string" value="tile_down_key"/>
      <property name="&lt;Alt&gt;F4" type="string" value="close_window_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_3" type="string" value="move_window_workspace_3_key"/>
      <property name="&lt;Primary&gt;F6" type="string" value="workspace_6_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Down" type="string" value="down_workspace_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_9" type="string" value="move_window_workspace_9_key"/>
      <property name="&lt;Super&gt;KP_Up" type="string" value="tile_up_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;End" type="string" value="move_window_next_workspace_key"/>
      <property name="&lt;Primary&gt;F8" type="string" value="workspace_8_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Left" type="string" value="move_window_left_key"/>
      <property name="&lt;Super&gt;KP_Right" type="string" value="tile_right_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_4" type="string" value="move_window_workspace_4_key"/>
      <property name="Right" type="string" value="right_key"/>
      <property name="Down" type="string" value="down_key"/>
      <property name="&lt;Primary&gt;F3" type="string" value="workspace_3_key"/>
      <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Down" type="string" value="lower_window_key"/>
      <property name="&lt;Primary&gt;F9" type="string" value="workspace_9_key"/>
      <property name="&lt;Alt&gt;Tab" type="string" value="cycle_windows_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Right" type="string" value="move_window_right_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Right" type="string" value="right_workspace_key"/>
      <property name="&lt;Alt&gt;F6" type="string" value="stick_window_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_5" type="string" value="move_window_workspace_5_key"/>
      <property name="&lt;Primary&gt;F11" type="string" value="workspace_11_key"/>
      <property name="&lt;Alt&gt;F10" type="string" value="maximize_window_key"/>
      <property name="&lt;Alt&gt;Delete" type="string" value="del_workspace_key"/>
      <property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;d" type="string" value="show_desktop_key"/>
      <property name="&lt;Primary&gt;F4" type="string" value="workspace_4_key"/>
      <property name="&lt;Super&gt;KP_Page_Up" type="string" value="tile_up_right_key"/>
      <property name="&lt;Alt&gt;F7" type="string" value="move_window_key"/>
      <property name="Up" type="string" value="up_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_6" type="string" value="move_window_workspace_6_key"/>
      <property name="&lt;Alt&gt;F11" type="string" value="fullscreen_key"/>
      <property name="&lt;Alt&gt;space" type="string" value="popup_menu_key"/>
      <property name="&lt;Super&gt;KP_Home" type="string" value="tile_up_left_key"/>
      <property name="Escape" type="string" value="cancel_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_1" type="string" value="move_window_workspace_1_key"/>
      <property name="&lt;Super&gt;KP_Next" type="string" value="tile_down_right_key"/>
      <property name="&lt;Super&gt;KP_Left" type="string" value="tile_left_key"/>
      <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Up" type="string" value="raise_window_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Home" type="string" value="move_window_prev_workspace_key"/>
      <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="string" value="cycle_reverse_windows_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Left" type="string" value="left_workspace_key"/>
      <property name="&lt;Alt&gt;F12" type="string" value="above_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Up" type="string" value="move_window_up_key"/>
      <property name="&lt;Primary&gt;F5" type="string" value="workspace_5_key"/>
      <property name="&lt;Alt&gt;F8" type="string" value="resize_window_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_7" type="string" value="move_window_workspace_7_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_2" type="string" value="move_window_workspace_2_key"/>
      <property name="&lt;Super&gt;KP_End" type="string" value="tile_down_left_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Up" type="string" value="up_workspace_key"/>
      <property name="&lt;Alt&gt;F9" type="string" value="hide_window_key"/>
      <property name="&lt;Primary&gt;F7" type="string" value="workspace_7_key"/>
      <property name="&lt;Primary&gt;F10" type="string" value="workspace_10_key"/>
      <property name="Left" type="string" value="left_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;KP_8" type="string" value="move_window_workspace_8_key"/>
      <property name="&lt;Alt&gt;Insert" type="string" value="add_workspace_key"/>
      <property name="&lt;Primary&gt;F1" type="string" value="workspace_1_key"/>
      <property name="override" type="bool" value="true"/>
    </property>
  </property>
  <property name="providers" type="array">
    <value type="string" value="xfwm4"/>
    <value type="string" value="commands"/>
  </property>
</channel>
" > /home/"$NEWUSER"/.config/xfce4/xfconf/xfce4-perchannel-xml/xfce4-keyboard-shortcuts.xml
    XFCONF_WALLPAPER_PATH="/home/$NEWUSER/.config/xfce4/xfconf/xfce4-perchannel-xml/xfce4-desktop.xml"
    mkdir -p /home/"$NEWUSER"/.config/xfce4/xfconf/xfce4-perchannel-xml
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<channel name=\"xfce4-desktop\" version=\"1.0\">
  <property name=\"backdrop\" type=\"empty\">
    <property name=\"screen0\" type=\"empty\">
      <property name=\"monitor0\" type=\"empty\">
        <property name=\"workspace0\" type=\"empty\">
          <property name=\"color-style\" type=\"int\" value=\"0\"/>
          <property name=\"image-style\" type=\"int\" value=\"0\"/>
          <property name=\"last-image\" type=\"string\" value=\"\"/>
          <property name=\"single-color\" type=\"string\" value=\"#000000\"/>
        </property>
      </property>
    </property>
  </property>
</channel>" > "$XFCONF_WALLPAPER_PATH"
chown "$NEWUSER":"$NEWUSER" -R /home/"$NEWUSER"/.config/xfce4
    mkdir -p /home/"$NEWUSER"/.config/autostart
    echo "[Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Type=Application
    Name=Tint2
    Exec=tint2
    StartupNotify=false
    Terminal=false
    Hidden=false" > /home/"$NEWUSER"/.config/autostart/tint2.desktop
    chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/autostart/tint2.desktop
    echo "Installing DE Packages & Some Extras."
    pacman -S --noconfirm xfce4 volctl pasystray xfce4-whiskermenu-plugin pcmanfm flatpak kvantum mpv tint2 papirus-icon-theme networkmanager xfce4-battery-plugin xfce4-notifyd xfce4-pulseaudio-plugin fastfetch cpufetch htop pipewire-alsa pipewire-pulse pipewire-jack pipewire bash-completion mpd kitty ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji adwaita-icon-theme w3m firefox udisks2 gvfs network-manager-applet pavucontrol firefox-i18n-en-us firefox-i18n-id firefox-ublock-origin firefox-dark-reader firefox-decentraleyes firefox-tree-style-tab
# pacman -S --noconfirm kate gparted xarchiver xfce4-screenshooter xfce4-mount-plugin xfce4-mpc-plugin xfce4-clipman-plugin lutris steam mangohud
# sudo -u "$NEWUSER" flatpak --noninteractive --user -y install sober zoom zapzap telegram
    echo "hwdec=vaapi
    cache=yes
    demuxer-max-bytes=150MiB
    demuxer-readahead-sec=60
    vo=gpu
    cscale=bilinear
    tscale=linear
    interpolation=no
    vd-lavc-threads=auto
    ao=pipewire" > /home/"$NEWUSER"/.config/mpv/mpv.conf
    GTK_CONFIG_PATH="/home/$NEWUSER/.config/gtk-3.0"
    GTK_CSS_FILE="$GTK_CONFIG_PATH/gtk.css"
    mkdir -p "$GTK_CONFIG_PATH"
    echo "
/* Force TRUE BLACK (#000000) on primary background and surface colors */
@define-color theme_bg_color #000000;
@define-color theme_base_color #000000;

.background,
window,
.view,
.flat-button,
.sidebar,
.frame,
.list-row,
.headerbar,
.titlebar,
.menubar,
.toolbar,
.notebook tab:not(:checked) {
    background-color: #000000;
    color: #FFFFFF; /* Pastikan teks tetap putih */
}

/* Ensure selected items and input fields remain usable */
.entry,
.text-view,
.entry:focus,
.text-view:focus {
    background-color: #111111; /* Biarkan input fields sedikit berbeda agar terlihat */
    color: #FFFFFF;
}

/* Ensure selection color is not black */
.selection {
    background-color: #406080; /* Blue-ish selection color */
}
" > "$GTK_CSS_FILE"
    chown -R "$NEWUSER":"$NEWUSER" "$GTK_CONFIG_PATH"
    sudo -u "$NEWUSER" xfconf-query -c xsettings -p /Net/ThemeName -s "Materia-dark" --create -t string
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
    read -r -p "minimalistui finished installing, enter '1' to exit (make sure to unplug the installation media too after this)" EXITRESPONSE
    if [[ "$EXITRESPONSE" =~ ^[1]$ ]]; then
    umount -R /mnt
    exit
    break
    else
    continue
    fi
    done
