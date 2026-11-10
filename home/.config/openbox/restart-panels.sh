#!/bin/sh
exec >>/tmp/restart.log 2>&1; echo "== $(date +%T) restart-panels"
# restart paskow i kompozytora Z LOKALNEJ SESJI (Openbox) - polkit pozwala wtedy zarzadzac siecia
. "$HOME/.config/rofi/locale-fix.sh"
pkill polybar; pkill tint2; pkill dunst; pkill nm-applet
sleep 1
feh --no-fehbg --bg-fill "$HOME/Pictures/wall-original.jpg" &
dunst >/dev/null 2>&1 &
(sleep 1; polybar main >/tmp/polybar.log 2>&1) &
tint2 >/dev/null 2>&1 &
nm-applet >/dev/null 2>&1 &
