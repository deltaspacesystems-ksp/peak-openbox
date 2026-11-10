#!/bin/sh
# Copies the desktop config into $HOME (existing files are saved as *.bak-<date>). Hard-coded /home/microfw paths are rewritten to $HOME.
# Usage: ./install.sh            (desktop config only)
set -eu
here=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
cd "$here/home"
find . -type f | while read -r f; do
    dest="$HOME/${f#./}"
    mkdir -p "$(dirname "$dest")"
    [ ! -e "$dest" ] || cp -p "$dest" "$dest.bak-$stamp"
    sed "s|/home/microfw|$HOME|g" "$f" > "$dest"
    [ ! -x "$f" ] || chmod +x "$dest"
done
echo "Installed into $HOME. Put a wallpaper at ~/Pictures/luca-micheli-wallpaper.jpg (or edit ~/.config/openbox/autostart)."
echo "Log out / restart Openbox to apply. The y5-phone/ folder is for the Huawei Y5 port only and is not installed."
