#!/bin/sh
# screenshot.sh region | full | color

set -eu

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$DIR"
stamp=$(date +%Y-%m-%d_%H-%M-%S)
out="$DIR/$stamp.png"

notify() {
	command -v notify-send >/dev/null 2>&1 && notify-send -a mango "$1" "$2" || true
}

flameshot_wayland() {
  env XDG_CURRENT_DESKTOP=mango XDG_SESSION_DESKTOP=mango QT_QPA_PLATFORM=wayland flameshot "$@"
}

case "${1:-region}" in
region)
	flameshot_wayland gui --path "$out" --clipboard
	[ -s "$out" ] && notify "Screenshot" "$out"
	;;
full)
	flameshot_wayland full --path "$out" --clipboard
	[ -s "$out" ] && notify "Screenshot" "$out"
	;;
color)
	geom=$(slurp -p -b 00000000 -c 89b4faff) || exit 0
	hex=$(grim -g "$geom" -t ppm - | magick - -format '%[hex:p{0,0}]' info: 2>/dev/null || true)
	if [ -z "$hex" ]; then
		notify "Color picker" "ImageMagick magick is not installed"
		exit 1
	fi
	printf '#%s\n' "$hex" | wl-copy
	notify "Color" "#$hex"
	;;
*)
	echo "usage: screenshot.sh region|full|color" >&2
	exit 1
	;;
esac
