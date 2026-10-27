#!/bin/sh
# Session menu. fuzzel only.

set -eu

choice=$(printf '%s\n' lock suspend logout reboot shutdown \
	| fuzzel --dmenu --prompt "power  " --width 24 --lines 5) || exit 0

lock() {
	pidof swaylock >/dev/null 2>&1 && return 0
	swaylock -f -c 101520 \
		--indicator-radius 80 --indicator-thickness 8 \
		--ring-color 6c7e97 --key-hl-color 89b4fa \
		--inside-color 101520 --line-color 00000000 \
		--separator-color 00000000 --text-color d1dae8 \
		--inside-ver-color 101520 --ring-ver-color 8fba7c \
		--inside-wrong-color 101520 --ring-wrong-color ad401f &
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
