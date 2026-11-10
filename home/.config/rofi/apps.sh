#!/bin/bash
# wspolny silnik menu Apps / Spotlight:  apps.sh launcher|spotlight
export PATH="$HOME/.local/bin:$PATH"
# lista aplikacji z plikow .desktop; wpisz "term <komenda>" (lub "> <komenda>") -> xterm z ta komenda
. "$HOME/.config/rofi/locale-fix.sh"
pkill -x rofi && exit 0
if [ "${1:-launcher}" = spotlight ]; then THEME=spotlight.rasi; PROMPT=Search; else THEME=launcher.rasi; PROMPT=Apps; fi

names=(); ids=(); icons=()
while IFS=$'\t' read -r name id icon; do
    names+=("$name"); ids+=("$id"); icons+=("$icon")
done < <(awk '
function emit() { if (f != "" && type == "Application" && !nod && !only && name != "") {
    id = f; sub(/.*\//, "", id); sub(/\.desktop$/, "", id); print name "\t" id "\t" icon } }
FNR == 1 { emit(); f = FILENAME; sec = ""; name = ""; icon = ""; nod = 0; type = ""; only = 0 }
/^\[/ { sec = $0; next }
sec == "[Desktop Entry]" {
    k = $0; sub(/=.*/, "", k); v = $0; sub(/^[^=]*=/, "", v)
    if (k == "Name" && name == "") name = v
    else if (k == "Icon") icon = v
    else if (k == "Type") type = v
    else if ((k == "NoDisplay" || k == "Hidden") && v == "true") nod = 1
    else if (k == "OnlyShowIn") only = 1
}
END { emit() }' /usr/share/applications/*.desktop "$HOME"/.local/share/applications/*.desktop 2>/dev/null | sort -f -t$'\t' -k1,1)

out=$( for i in "${!names[@]}"; do printf '%s\0icon\x1f%s\x1fmeta\x1f%s\n' "${names[i]}" "${icons[i]}" "${ids[i]}"; done \
       | rofi -dmenu -i -format 'i|f' -p "$PROMPT" -show-icons -icon-theme Papirus-Dark \
              -theme "$HOME/.config/rofi/$THEME" ) || exit 0
idx=${out%%|*}; txt=${out#*|}
txt="${txt#"${txt%%[![:space:]]*}"}"

# "term <komenda>" / "> <komenda>"  -> xterm z komenda (okno zostaje po zakonczeniu)
if [[ $txt =~ ^(term[[:space:]]+|\>[[:space:]]*)(.+)$ ]]; then
    exec xterm -hold -e sh -c "${BASH_REMATCH[2]}"
elif [[ $txt =~ ^term[[:space:]]*$ ]]; then
    exec xterm
fi

if [ "$idx" -ge 0 ] 2>/dev/null; then
    setsid -f gtk-launch "${ids[$idx]}" >/dev/null 2>&1
elif [ -n "$txt" ]; then
    first=${txt%%[[:space:]]*}
    if command -v "$first" >/dev/null 2>&1; then
        setsid -f sh -c "$txt" >/dev/null 2>&1
    else
        rofi -e "Not found: $first   (tip: term <command> opens it in xterm)" -theme "$HOME/.config/rofi/$THEME"
    fi
fi
