#!/bin/sh
# Capture through wlroots-native tools; Flameshot 12 cannot capture on MangoWM.
# screenshot.sh region | full | color

set -eu

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$DIR"
stamp=$(date +%Y-%m-%d_%H-%M-%S)
out="$DIR/$stamp.png"

notify() {
	command -v notify-send >/dev/null 2>&1 && notify-send -a mango "$1" "$2" || true
}

save_screenshot() {
	if [ "$1" = region ]; then
		geom=$(slurp) || exit 0
		grim -g "$geom" "$out"
	else
		grim "$out"
	fi
	wl-copy --type image/png < "$out"
	notify "Screenshot" "$out"
}

case "${1:-region}" in
region)
	save_screenshot region
	;;
full)
	save_screenshot full
	;;
color)
	geom=$(slurp -p -b 00000000 -c 81a1c1ff) || exit 0
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
