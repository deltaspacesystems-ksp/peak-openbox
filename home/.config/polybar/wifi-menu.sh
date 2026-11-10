#!/bin/bash
. "$HOME/.config/rofi/locale-fix.sh"
# male menu rofi pod paskiem: przelacznik Wi-Fi, lista sieci, polaczenie; haslo wpisujesz sam
THEME="$HOME/.config/rofi/mocha.rasi"
menu() { rofi -dmenu -i -format i -theme "$THEME" "$@"; }
msg()  { rofi -e "$1" -theme "$THEME"; }

# Wi-Fi wylaczone: tylko przelacznik
if [ "$(nmcli radio wifi)" != enabled ]; then
    i=$(printf 'Wi-Fi switch:  OFF   (click to turn on)\n' | menu -p "Wi-Fi") || exit 0
    [ "$i" = 0 ] && nmcli radio wifi on
    exit 0
fi

mapfile -t rows < <(nmcli -t -e no -f SIGNAL,SECURITY,IN-USE,SSID dev wifi list --rescan no 2>/dev/null \
    | sort -t: -k1,1nr | awk -F: '$4!="" && !seen[$4]++')
ssids=(); secs=(); uses=(); lines=()
for r in "${rows[@]}"; do
    IFS=: read -r sig sec use ssid <<<"$r"
    mark="   "; [ "$use" = "*" ] && mark="●  "
    lock=""; [ -n "$sec" ] && [ "$sec" != "--" ] && lock="   secured"
    ssids+=("$ssid"); secs+=("$sec"); uses+=("$use")
    lines+=("$(printf '%s%s   %s%%%s' "$mark" "$ssid" "$sig" "$lock")")
done
n=${#ssids[@]}
# indeks 0 = przelacznik, 1..n = sieci, potem Rescan i ustawienia
all=("Wi-Fi switch:  ON   (click to turn off)" "${lines[@]}" "Rescan" "Network settings...")

sel=$(printf '%s\n' "${all[@]}" | menu -p "Wi-Fi") || exit 0
if   [ "$sel" = 0 ];            then nmcli radio wifi off; exit 0
elif [ "$sel" = "$((n+1))" ];   then nmcli dev wifi rescan >/dev/null 2>&1; sleep 2; exec "$0"
elif [ "$sel" = "$((n+2))" ];   then exec nm-connection-editor
fi

i=$((sel-1))
ssid=${ssids[$i]}; sec=${secs[$i]}
if [ "${uses[$i]}" = "*" ]; then          # klik w polaczona siec = rozlacz
    nmcli device disconnect wlan0 >/dev/null 2>&1; exit 0
fi
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" >/dev/null 2>&1 && exit 0
fi
if [ -n "$sec" ] && [ "$sec" != "--" ]; then
    pw=$(printf '' | rofi -dmenu -password -p "Password" -mesg "$ssid" -theme "$THEME" \
         -theme-str 'listview { enabled: false; }') || exit 0
    [ -n "$pw" ] || exit 0
    printf '%s\n' "$pw" | nmcli --ask device wifi connect "$ssid" >/dev/null 2>&1 \
        || msg "Could not connect to $ssid"
else
    nmcli device wifi connect "$ssid" >/dev/null 2>&1 || msg "Could not connect to $ssid"
fi
