#!/bin/bash

# Define the user
TARGET_USER="$NEWUSER"
USER_HOME="/home/$TARGET_USER"

# 1. Create .bash_profile
# Note: Using 'EOF' (with quotes) prevents the current shell from 
# evaluating variables like $DISPLAY or $S before they are written.
cat << 'EOF' > "$USER_HOME/.bash_profile"
while true; do
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        read -r -p "Do you want to login into a GUI session or stay in TTY? ('1' for GUI, '0' for TTY): " R
        case $R in
            1) 
                declare -A desktops
                [[ -f /usr/bin/startminuix ]] && desktops[MinimalistUI-X11]="startminuix"
                [[ -f /usr/bin/startminuiw ]] && desktops[MinimalistUI-WYL]="startminuiw"
                [[ -f /usr/bin/startxfce4 ]] && desktops[XFCE4]="startxfce4"
                [[ -f /usr/bin/startplasma-x11 ]] && desktops[KDE]="startplasma-x11"
                [[ -f /usr/bin/gnome-session ]] && desktops[GNOME]="gnome-session"
                [[ -f /usr/bin/i3 ]] && desktops[i3]="i3"
                
                count=${#desktops[@]}
                
                if [ "$count" -gt 1 ]; then
                    echo "Multiple environments detected:"
                    select choice in "${!desktops[@]}" "Terminal-Only"; do
                        if [[ -n $choice && $choice != "Terminal-Only" ]]; then
                            export S=${desktops[$choice]}
                            exec startx
                        else
                            echo "Aborting GUI launch."
                            break
                        fi
                    done
                elif [ "$count" -eq 1 ]; then
                    # Get the only key in the array
                    B="${!desktops[@]}"
                    export S=${desktops[$B]}
                    exec startx
                else
                    echo "No GUI environments found in /usr/bin/."
                    sleep 2
                fi
                ;;
            0) 
                break 
                ;;
            *) 
                echo "Invalid input."
                continue 
                ;;
        esac
    else
        break
    fi
done
EOF

# 2. Create .xinitrc
cat << 'EOF' > "$USER_HOME/.xinitrc"
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# If $S was exported from .bash_profile, run it.
# Otherwise, default to xfce4 or a safe fallback.
if [ -n "$S" ]; then
    exec $S
else
    # Fallback to xfce if installed, otherwise just a terminal
    if [ -f /usr/bin/startminui ]; then
        exec startminui
    else
        exec xterm
    fi
fi
EOF

# Ensure the new user owns these files
chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.bash_profile" "$USER_HOME/.xinitrc"
