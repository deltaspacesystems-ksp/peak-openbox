#!/bin/sh
if gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.NameHasOwner org.onboard.Onboard | grep -q true; then
    gdbus call --session --dest org.onboard.Onboard \
    --object-path /org/onboard/Onboard/Keyboard \
    --method org.onboard.Onboard.Keyboard.ToggleVisible >/dev/null
    exit $?
fi

gsettings set org.onboard.window docking-enabled false
gsettings set org.onboard.window window-decoration true
gsettings set org.onboard.window force-to-top false
set -- $(xdotool getdisplaygeometry)
width=760
height=240
[ "$width" -le "$(( $1 - 24 ))" ] || width=$(( $1 - 24 ))
x=$(( ($1 - width) / 2 ))
y=$(( $2 - height - 58 ))
exec onboard --size "${width}x${height}" -x "$x" -y "$y"
