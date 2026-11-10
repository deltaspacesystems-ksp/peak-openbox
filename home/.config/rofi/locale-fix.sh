# source'owane: jesli LANG/LC_TIME wskazuja nieistniejacy locale, rofi sie zamyka -> fallback
_loc_ok() { locale -a 2>/dev/null | grep -qixF "$(printf '%s' "$1" | sed 's/UTF-8/utf8/I')"; }
if [ -n "$LANG" ] && ! _loc_ok "$LANG"; then export LANG=C.UTF-8; fi
if [ -n "$LC_TIME" ] && ! _loc_ok "$LC_TIME"; then unset LC_TIME; fi
unset LC_ALL
