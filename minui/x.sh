#!/bin/bash
source /v.sh
chmod +x startminuix
chmod +x startminuiw
chmod +x mkisosfs.sh
chmod +x mkiso.sh
chmod +x tint2.desktop
chmod +x login.sh
chmod +x l.sh
mkdir -p /usr/minui/
mkdir -p /usr/minui/backgrounds/
mkdir -p /usr/minui/bin/
mkdir -p /usr/minui/config/
mkdir -p /usr/local/bin/minui/
sh login.sh
[[ ! "$RI" == "5" ]] && chmod +x c.sh &&
sh c.sh &&
mv mpv.conf /home/"$NEWUSER"/.config/mpv/mpv.conf &&
chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/mpv/mpv.conf &&
cp l.sh /home/"$NEWUSER"/.config/labwc/autostart &&
chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/labwc/autostart &&
cp tint2.desktop /home/"$NEWUSER"/.config/autostart/tint2.desktop &&
chown "$NEWUSER":"$NEWUSER" /home/"$NEWUSER"/.config/autostart/tint2.desktop &&
cp t2rc /usr/minui/config/tint2rc &&
cp startminuiw /usr/minui/bin/startminuiw
cp wp.png /usr/minui/backgrounds/wp.png
cp osr /usr/lib/os-release
cp startminuix /usr/minui/bin/startminuix
cp mkisosfs.sh /usr/minui/bin/mkisosfs.sh
cp mkiso.sh /usr/minui/bin/mkiso.sh
ln -sf /usr/lib/os-release /usr/minui/os-release
ln -sf /usr/minui/bin/ /usr/local/bin/minui/
exit 0
