# peak-openbox

Openbox desktop (Catppuccin Mocha) from the Huawei Y5 Linux port

The desktop config of a mainline-Linux phone: Huawei Y5 2018 (MT6739) running Alpine with kernel 7.3.
The desktop part (`home/`) is ordinary Openbox dotfiles and works on any Linux machine. The Y5-specific
glue is kept apart in `y5-phone/`.

## What it is

| Part | Role |
|------|------|
| **Openbox** | window manager (`~/.config/openbox`): keybindings in `rc.xml`, root menu in `menu.xml`, startup in `autostart` |
| **polybar** | top bar: launcher button, on-screen keyboard toggle, workspaces; volume, Wi-Fi, clock on the right |
| **tint2** | bottom panel with the task list and system tray (`nm-applet` lives there) |
| **picom** | compositor (shadows, transparency) |
| **rofi** | app launcher (`Ctrl+Super`) and a Spotlight-style search (`Alt+Space` / `Super`), Catppuccin theme in `mocha.rasi` |
| **dunst** | notifications |
| **feh** | wallpaper |
| **onboard** | on-screen keyboard, toggled by `openbox/keyboard-toggle.sh` (polybar button) |
| Wi-Fi menu | `polybar/wifi-*.sh`: `nmcli` + rofi, click the Wi-Fi module |

Everything is themed with the Catppuccin Mocha palette; GTK/Qt dark mode is set in `openbox/environment`.

## Startup flow

`xinit`/a display manager runs `openbox-session` (see `.xinitrc`). Openbox then runs `~/.config/openbox/autostart`:
`.Xresources` is merged (DPI, terminal font), the wallpaper is set, then dunst, polybar, tint2 and `nm-applet` start.
`Ctrl+Alt+R` restarts the panels (`restart-panels.sh`).

## Keys

| Key | Action |
|-----|--------|
| `Alt+Space` / `Super` | rofi search |
| `Ctrl+Super` | rofi app launcher |
| `Ctrl+Alt+T` | terminal (xterm) |
| `Ctrl+Alt+R` | restart polybar/tint2/picom |
| `Ctrl+Alt+Arrows` / `Shift+Alt+Arrows` | switch desktop / move window to desktop |
| `Super+F1..F4` | go to desktop 1..4 |

## Install

```sh
git clone <this repo> && cd <this repo>
./install.sh
```

`install.sh` copies `home/` into `$HOME` (existing files are saved as `*.bak-<timestamp>`) and rewrites the
hard-coded `/home/microfw` paths to your `$HOME`.

Packages (Alpine names; Debian/Arch are the same programs): `openbox polybar tint2 picom rofi dunst feh
network-manager-applet onboard xdotool xterm`, the **JetBrainsMono Nerd Font**, and an Adwaita dark GTK theme.

Wallpaper: the image is **not** included. Put your own at `~/Pictures/luca-micheli-wallpaper.jpg`
or change the `feh` line in `~/.config/openbox/autostart`.

## Phone-specific part (`y5-phone/`, not installed by `install.sh`)

* `etc/X11/mfw-y5-landscape.conf` runs Xorg on the rotated `fbdev` framebuffer (`/dev/fb1`) of the Y5.
* `usr/local/sbin/mfw-openbox-session` starts Xorg on tty7 with a private auth cookie, then the Openbox session as an unprivileged user.
* The Openbox root menu has entries that only exist on the phone (USB mode / OTG host via `doas`); delete them in `menu.xml` elsewhere.

## License

MIT, see `LICENSE`.
