#!/bin/sh
# polybar: Wi-Fi off / Wi-Fi (szare, niepolaczone) / Wi-Fi 82% (polaczone)
if [ "$(nmcli radio wifi 2>/dev/null)" != enabled ]; then
    echo "%{F#6c7086}Wi-Fi off%{F-}"; exit 0
fi
sig=$(nmcli -t -f ACTIVE,SIGNAL dev wifi list --rescan no 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
if [ -n "$sig" ]; then
    echo "%{F#89b4fa}Wi-Fi%{F-} ${sig}%"
else
    echo "%{F#6c7086}Wi-Fi%{F-}"
fi
