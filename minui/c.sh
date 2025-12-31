#!/bin/bash
    echo "Creating command to switch cpu governor to performance or powersave (use command cpu-performance or cpu-powersave)"
    sh -c 'cat << EOF > /usr/minui/bin/cpu-maxperf
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
    chmod +x /usr/minui/bin/cpu-maxperf
    sudo sh -c 'cat << EOF > /usr/minui/bin/cpu-powersave
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
    chmod +x /usr/minui/bin/cpu-powersave
    echo "Creating command to increase or decrease brightness (use command brightness)"
    sh -c 'cat << EOF > /usr/minui/bin/brightness
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
    chmod +x /usr/minui/bin/brightness
    echo "Creating command to increase / decrease / mute volume (intended for cli environtment) (use command volume)"
    sh -c 'cat << EOF > /usr/minui/bin/volume
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
    chmod +x /usr/minui/bin/volume
    echo "Creating command to use mpv in CLI-only environtment (use command vlcwatch)"
    sh -c 'cat << EOF > /usr/minui/bin/mpvwatch
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
    chmod +x /usr/minui/bin/mpvwatch
    echo "For commands that are focused on CLI environtment thats from MinimalistUI, use command "ls /usr/minui/bin""
