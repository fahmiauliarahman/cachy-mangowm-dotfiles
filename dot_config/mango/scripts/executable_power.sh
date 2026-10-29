#!/bin/sh
# Session menu. fuzzel only.

set -eu

if [ "${1:-}" = lock ]; then
	choice=lock
else
	choice=$(printf '%s\n' lock suspend logout reboot shutdown \
		| fuzzel --dmenu --prompt "power  " --width 24 --lines 5) || exit 0
fi

lock() {
	pidof swaylock >/dev/null 2>&1 && return 0
	wallpaper="${XDG_CACHE_HOME:-$HOME/.cache}/mango/wallpaper"
	set -- -f \
		--indicator-radius 80 --indicator-thickness 8 \
		--ring-color 81a1c1 --key-hl-color 88c0d0 \
		--inside-color 2e3440 --line-color 00000000 \
		--separator-color 00000000 --text-color d8dee9 \
		--inside-ver-color 2e3440 --ring-ver-color a3be8c \
		--inside-wrong-color 2e3440 --ring-wrong-color bf616a \
		--text-ver-color d8dee9 --text-wrong-color d8dee9
	if [ -r "$wallpaper" ] && [ -r "$(cat "$wallpaper")" ]; then
		swaylock "$@" --image "$(cat "$wallpaper")" --scaling fill &
	else
		swaylock "$@" -c 2e3440 &
	fi
}

case "$choice" in
lock) lock ;;
suspend)
	lock
	sleep 0.4
	systemctl suspend
	;;
logout) mmsg dispatch quit ;;
reboot) systemctl reboot ;;
shutdown) systemctl poweroff ;;
esac
