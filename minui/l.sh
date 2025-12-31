#!/bin/sh
#
#  MinimalistUI Labwc Autostart
#  Location: ~/.config/labwc/autostart
#
swaybg -i /usr/minui/backgrounds/wp.png -m fill &
waybar &
mako &
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
